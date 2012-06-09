From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: formal way to map from pf to vfs when using VT-d?
Date: Fri, 8 Jun 2012 17:04:58 -0700
Message-ID: <20120608170458.00006e6e@unknown>
References: <4FD25D18.6090002@genband.com>
	<4FD26382.3050303@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48394 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761565Ab2FIAFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2012 20:05:02 -0400
In-Reply-To: <4FD26382.3050303@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jun 2012 14:41:38 -0600
Chris Friesen <chris.friesen@genband.com> wrote:

> On 06/08/2012 02:14 PM, Chris Friesen wrote:
> >
> > Hi,
> >
> > I'm using the igb/igbvf drivers.  If I set igb.max_vfs=7,7,7,7 it 
> > creates 7 vfs for each of my pfs.  So far so good.
> >
> > Now, how do I map from a given pf to the PCI addresses for the set
> > of vfs that are associated with it?  I don't have virsh installed,
> > so is there a way to query this with sysfs or something?
> >
> 
> I think I found it.../sys/class/net/eth0/device/ has "virtfnX"
> entries which are symlinks to the appropriate pci address.

Here's a script used by our validation team, inserted inline.

#!/usr/bin/perl
use strict;

if ($#ARGV <1)
{
        print " Usage: ./list_vfs.pl Nic_name (t for Twinville, n for niantic, k for kawela, p for powerville) port_numer( 1 for first port, 2 for second port..) \n";

        exit ;
}
my $nic_name=$ARGV[0];
#my $port_n=$ARGV[1]%4;
my $all_vfs;
my $vf_str;
my $mode = 2;
my $my_pf_str;

if ($nic_name eq 't') {
        $my_pf_str= "\"10 Gigabit\"";
	$vf_str="\"Intel Corporation Device 1515\"";
} elsif ($nic_name eq 'n') {
	$my_pf_str="\"82599EB\"";
	$vf_str="\"82599 Ethernet Controller Virtual\"";
} elsif ($nic_name eq 'k') {
	$my_pf_str="\"82576 Gigabit Network Connection\"";
	$vf_str="\"Intel Corporation 82576 Virtual Function\"";
} elsif ($nic_name eq 'p') {
	$my_pf_str= "\"I350\"";
	$vf_str="\"Intel Corporation Device 1520\"";
	$mode=4;
} else {
	print "No such virtual Function device, please check again\n";
}

my $port_n=$ARGV[1]%$mode;

my $my_pf=qx(lspci | grep $my_pf_str | awk '{print \$1}' | awk 'NR%$mode==$port_n');
print  "PF=$my_pf\n";
my $all_vfs=qx(lspci | grep $vf_str | awk '{print \$1}' | awk 'NR%$mode==$port_n');
print "VFs are:\n";
print "$all_vfs\n";

- Greg

> 
> Chris
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
