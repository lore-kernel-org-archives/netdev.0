From: "Eduard Guzovsky" <eguzovsky@gmail.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some time
Date: Sat, 27 Dec 2008 23:47:40 -0500
Message-ID: <1fd9f5a40812272047w464119f7l8796c7aa7a93576b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:43181 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685AbYL1Erl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 23:47:41 -0500
Received: by rv-out-0506.google.com with SMTP id k40so3989084rvb.1
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2008 20:47:40 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I even get the same error when doing a multicast ping6:
>  miredo:~# ping6 -I eth0 ff02::9
>  PING ff02::9(ff02::9) from fe80::216:3eff:feb9:29f5 eth0: 56 data by=
tes
>  ping: sendmsg: Invalid argument

We had a similar problem in our lab network. I tracked down the source
of the "Invalid argument" error to ip6_output_finish(). Here is the
stack

  -----edg ip6_output_finish: failed to find neighbour
  [<c010647a>] show_trace_log_lvl+0x1a/0x30
  [<c0106ba2>] show_trace+0x12/0x20
  [<c0106c09>] dump_stack+0x19/0x20
  [<f14ab019>] ip6_output2+0x279/0x290 [ipv6]
  [<f14ab40f>] ip6_output+0x2df/0x830 [ipv6]
  [<f14abce7>] ip6_push_pending_frames+0x247/0x420 [ipv6]
  [<f14bde2f>] udp_v6_push_pending_frames+0x13f/0x1f0 [ipv6]
  [<f14bf8fe>] udpv6_sendmsg+0x7ae/0xa60 [ipv6]
  [<c02ea254>] inet_sendmsg+0x34/0x60
  [<c0297adc>] sock_sendmsg+0xfc/0x120
  [<c029835f>] sys_sendto+0xbf/0xe0
  [<c0299a37>] sys_socketcall+0x187/0x260
  [<c0105b7b>] syscall_call+0x7/0xb
  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

ip6_output_finish() returns EINVAL because the route cache entry has
NULL as a "neighbour" pointer.

These invalid route cache entries are created when ipv6 neighbour
table is filled up (one potential reason for that is a combination of
a lot of multicast traffic =96"ff02:=85" and xen hosts with interfaces =
in
promiscuous mode). In this case ndisc_get_neigh() returns NULL, but at
least in two places the routing code in net/ipv6/route.c ignores it
and inserts invalid entries in the cache anyway.

This is especially bad for frequently used multicast addresses.
Garbage collector does not remove them from the cache, probably
because of the frequent updates of the "__use" count. You need to
flush the cache to get rid of them.

One way to work around the problem is to increase "gc_thresh3" for
ipv6 neighbour table. That still leaves you open for DOS attacks.
Another way is to create permanent entries in neighbor/routing tables.

In any case routing cache pollution problem has to be fixed. I suggest
the following patch. I do not know this code and would appreciate if
code maintainers could comment on it.

Thanks,

-Ed

--- a/net/ipv6/route.c  2008-12-26 14:56:50.000000000 -0500
+++ b/net/ipv6/route.c  2008-12-26 14:57:19.000000000 -0500
@@ -638,6 +638,11 @@

                rt->rt6i_nexthop =3D ndisc_get_neigh(rt->rt6i_dev,
&rt->rt6i_gateway);

+                if (rt->rt6i_nexthop =3D=3D NULL) {
+                    dst_free((struct dst_entry *)rt);
+                    rt =3D NULL;
+                }
+
        }

        return rt;
@@ -991,9 +996,18 @@
        dev_hold(dev);
        if (neigh)
                neigh_hold(neigh);
-       else
+       else {
                neigh =3D ndisc_get_neigh(dev, addr);

+                if (neigh =3D=3D NULL) {
+                    dev_put(dev);
+                    in6_dev_put(idev);
+                    dst_free((struct dst_entry *)rt);
+                    rt =3D NULL;
+                    goto out;
+                }
+        }
+
        rt->rt6i_dev      =3D dev;
        rt->rt6i_idev     =3D idev;
        rt->rt6i_nexthop  =3D neigh;
