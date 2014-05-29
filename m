From: Spike White <spikewhitetx@gmail.com>
Subject: Re: inconsistency of ethtool feature names for get vs. set
Date: Thu, 29 May 2014 14:40:54 +0000 (UTC)
Message-ID: <loom.20140529T162434-807@post.gmane.org>
References: <52C535B9.7080208@mellanox.com> <1388675034.1607.9.camel@bwh-desktop.uk.level5networks.com> <1388688114.9947.30.camel@bwh-desktop.uk.level5networks.com> <20140106235858.5ce80054.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48431 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757515AbaE2PPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:15:10 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Wq22o-0000pO-MT
	for netdev@vger.kernel.org; Thu, 29 May 2014 17:15:05 +0200
Received: from 108-90-112-141.lightspeed.austtx.sbcglobal.net ([108.90.112.141])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 17:15:02 +0200
Received: from spikewhitetx by 108-90-112-141.lightspeed.austtx.sbcglobal.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 17:15:02 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink <billfink <at> mindspring.com> writes:

> 
> On Thu, 2 Jan 2014, Ben Hutchings wrote:
> 
> > On Thu, 2014-01-02 at 15:03 +0000, Ben Hutchings wrote:
> > > On Thu, 2014-01-02 at 11:47 +0200, Or Gerlitz wrote:
> > [...]
> > > > $ ethtool -k eth1  | grep generic-receive-offload
> > > > generic-receive-offload: on
> > > > 
> > > > $ ethtool -K eth1  generic-receive-offload off
> > > > ethtool: bad command line argument(s)
> > > > For more information run ethtool -h
> > > > 
> > > > --> looking in the sources and realizing I need to use "rx-gro"
> > > 
> > > Or 'gro'.  All the old feature names that can be used with the -K 
option
> > > are listed in the manual page.  All the new feature names are 
consistent
> > > between -k/-K.
> > 
> > By 'new feature names' I mean names for features that weren't 
previously
> > exposed through ethtool.
> > 
> > [...]
> > > > Basically, this can be resolved by fairly simple patch, but I 
wasn't 
> > > > sure if you want it in user space, in the kernel or both...
> > > 
> > > How do you intend to resolve this, given the compatibility 
requirement
> > > that the old names must still be reported by -k and accepted by -K?
> > 
> > Just to be clear, I do see that there's a problem here but the fix may
> > have to be mostly or entirely in documentation rather than code.
> 
> Wouldn't one simple option be to allow the long form like
> generic-receive-offload for setting in addition to the existing
> shortcuts rx-gro and gro?  That way a user doing "ethtool -k"
> could use the name provided to do a set via "ethtool -K" without
> needing to consult a man page (or "ethtool -h"), while still
> allowing more knowledgeable users to use the shortcut names.
> 
> 					-Bill
> 

I love Bill's suggestion. 

For instance, I have a mandate from my network engineering team to disable 
all offloads on all Linux VMs.  (don't ask).

I plagiarized the below code.  But it uses the same keywords that it gets 
from -k to call -K.  So it fails.

So I have to continue to play whack-a-mole.  As new offloads arise, 
decipher the translation (via viewing man pages, etc.)

#==================================================
# TCP Offloading
# Guidance from network engineering to disable all offloads on all NICs:
# rx tx sg tso ufo gso gro lro rxvlan txvlan rxhash
function fix_offload () {

NICS=$(ifconfig | awk '/^p[0-9][^:]/ || /^eth[0-9][^:]/ || /^em[0-9][^:]/ 
{print $1}')

MODEL=$(dmidecode | grep -i product | head -1 | cut -f2 -d':' | cut -c 2-)

if [[ $MODEL = VMware* ]] && [[ $OS = "OEL6" ]]
then
   # New offloads in OEL6 that ethtool cannot disable on VM's: rxvlan, 
txvlan, & rxhash
   ETHTOOL_PARSE="egrep -v -e 'vlan' -e 'hashing'"
elif [[ -n "$UEK" ]]
then
   # UEK has a bunch of features that we don't care about, so specify what 
we want
   ETHTOOL_PARSE="egrep -e 'checksumming' -e 'scatter' -e 'offload' -
e 'hashing'"
else
   # Grab everything
   ETHTOOL_PARSE="grep ':'"
fi

for i in $NICS
do
   OFFLOADS_ON=$(ethtool -k $i 2> /dev/null | eval $ETHTOOL_PARSE | 
grep ': on' | awk -F: '{print $1 off}')
   if [[ -n "$OFFLOADS_ON" ]]
   then
      echo "NIC $i offloads on"
      ethtool -K $i $OFFLOADS_ON
   else
      echo "PASS: NIC $i offloads off"
   fi
done

}
