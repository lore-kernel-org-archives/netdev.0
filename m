From: "Johnson, Chester F" <chester.f.johnson@intel.com>
Subject: RE: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 15:36:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7E713DB94F47914DB5AAB80DE8EEA87501539908@fmsmsx410.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <niv@us.ibm.com>, <ak@suse.de>, <ruddk@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>, "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm trying to think through one potential issue with ignoring the TOS
field. Would/should a route redirect have to match the same src-dst-tos
hash?

1. Assume the network uses DSCP to make routing decisions.
2. Assume the first hop routers are configured as passive and do not
advertise routes to the supported subnets and presumes static routes
configured on end hosts.
3. The Linux host has multiple network interfaces for route diversity.

The preferred route may send the frame to the wrong router and then
ignore the icmp route redirect. Or would it?

chet

-----Original Message-----
From: David S. Miller [mailto:davem@redhat.com] 
Sent: Wednesday, December 10, 2003 3:21 PM
To: Julian Anastasov
Cc: niv@us.ibm.com; ak@suse.de; ruddk@us.ibm.com; kuznet@ms2.inr.ac.ru;
netdev@oss.sgi.com; Johnson, Chester F
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)


On Thu, 11 Dec 2003 01:15:06 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> It seems, there are no many users of OIF!=0 but if TOS is used as 
> routing key we can see up to 8 entries with different TOS for same 
> SADDR,DADDR. Of course, it looks difficult to walk 8 rows just to 
> check all TOS variants, the common case is to see only one TOS value 
> used. That is why I propose to eliminate the TOS as hash key and to 
> walk one row. At first look, the risk of DoS is same, thanks to the 
> random value.

This is not my understanding at all.

Consider the case where we generate routing cache entries for all 8 TOS
values.  Currently we'll likely get a O(1) lookup for any one of those
entries.

Your proposal guarentees that all such entries will land to the same
hash chain, since TOS is not an input for the hash any longer. Therefore
the lookup in my example case will be O(8).

And instead of just eating the complexity at ICMP PMTU handling time, we
eat the complexity at every routing cache lookup.

I really don't think we can consider this.
