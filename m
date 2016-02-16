From: David Lamparter <equinox@diac24.net>
Subject: Re: [net-next] net: l3mdev: address selection should only consider
 devices in L3 domain
Date: Wed, 17 Feb 2016 00:41:15 +0100
Message-ID: <20160216234115.GI659150@eidolon>
References: <1455663591-27615-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david@opensourcerouting.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([85.239.127.252]:43492 "EHLO eidolon.nox.tf"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933313AbcBPXsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 18:48:41 -0500
Content-Disposition: inline
In-Reply-To: <1455663591-27615-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, unfortunately...  [below]

On Tue, Feb 16, 2016 at 02:59:51PM -0800, David Ahern wrote:
> +++ b/net/ipv4/devinet.c
> @@ -1214,12 +1215,16 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
>  	if (addr)
>  		goto out_unlock;
>  no_in_dev:
> +	master_idx = l3mdev_master_ifindex_rcu(dev);
>  
>  	/* Not loopback addresses on loopback should be preferred
>  	   in this case. It is important that lo is the first interface
>  	   in dev_base list.
>  	 */
>  	for_each_netdev_rcu(net, dev) {
> +		if (l3mdev_master_ifindex_rcu(dev) != master_idx)
> +			continue;
> +
>  		in_dev = __in_dev_get_rcu(dev);
>  		if (!in_dev)
>  			continue;

... this won't do enough.  If you look at the 4.3 patch I sent you, I
was adding a comment:

+ /* For VRFs, the VRF device takes the place of the loopback device,
+    with addresses on it being preferred.  Note in such cases the
+    loopback device will be among the devices that fail the vrf_ifi
+    equality check in the loop below.
+  */

And then it goes on to try the vrf0 interface before anything else.
This is needed for a case like this - note the interface indexes:

123: some_internal: <...> master vrf0
    inet 192.168.123.45/24 scope global
234: my_unnumbered: <...> master vrf0
    # no address
345: vrf0: <...>
    inet 198.145.20.140/32 scope global

Since the "some_internal" interface will be hit before the "vrf0"
interface, the 192.168.123.45 address will be selected as source.  This
is quite likely not what the administrator intended, and in fact it's
suddenly hard for the admin to influence the system to get the correct
result.  (prefsrc on routes would work, but try beating that into
dynamic routing.)

This is also why there is that other comment that is included in your
context diff, about "important that lo is the first interface in
dev_base list".

I'll send a patch (on top of your patch) to get this behavior in a few
minutes.


-David
