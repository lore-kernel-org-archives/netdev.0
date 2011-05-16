From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 1/1] igmp: fix ip_mc_clear_src to not reset ip_mc_list->sf{mode,count}
Date: Mon, 16 May 2011 13:42:11 -0700
Message-ID: <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com>
References: <20110515165945.GA20024@darkmag.usersys.redhat.com> <20110516.140359.111037536766782557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	mmarek@suse.cz, netdev@vger.kernel.org, pekkas@netcore.fi,
	vfalico@redhat.com, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20110516.140359.111037536766782557.davem@davemloft.net>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Veaceslav Falico <vfalico@redhat.com>
> Date: Sun, 15 May 2011 18:59:45 +0200
> 
> > ip_mc_clear_src resets the imc->sfcount and imc->sfmode, without 
taking into
> > account the current number of sockets listening on that multicast 
> struct, which
> > can lead to bogus routes for local listeners.
> > 
> > On NETDEV_DOWN/UP event, if there were 3 multicast listeners for 
> that interface's
> > address, the imc->sfcount[MCAST_EXCLUDE] will be reset to 1. And 
> after that a
> > listener socket destroys, multicast traffic will not be delivered to 
local
> > listeners because __mkroute_output drops the local flag for the route 
(by
> > checking ip_check_mc).

        On NETDEV_DOWN, all group memberships are dropped. 
ip_mc_clear_src()
is simply freeing all the source filters and turning it into an "EXCLUDE 
nobody"
membership (ie, the same as an ordinary join without source filtering). 
This
ordinarily happens when you are deleting the group entirely (when the 
reference
count goes to 0), but is also called on device down.
        This patch is not appropriate; when the groups are deleted, the 
source
filters are deleted, and the filter counts have to reflect the source 
filters
in the list. If you had an "INCLUDE A" filter, for example, that would 
become
an "INCLUDE nobody" filter and drop all traffic (from A or not). The 
number
of source filters is not related to the number of listener sockets, and 
the
function of ip_mc_clear_src() is to make it 0 (with the special case of 1 
for
EXCLUDE), so setting the counts has to be done for proper functioning.
        I don't quite understand the problem you're trying to solve here 
--
when the device comes back up, the group should be re-added with 
{EXCLUDE,nobody} and
ip_check_mc() should therefore return 1. Of course, while the interface is
down, the mc_list is empty and it'd return 0 in that case.
        Do you have a small test program to demonstrate the problem?

        For the patch, I have to say NACK.

                                                                +-DLS


