From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Mon, 24 Jul 2017 11:09:07 +0800
Message-ID: <20170724030907.GC2938@leo.usersys.redhat.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36340 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbdGXDJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 23:09:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id 1so1295132pfi.3
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 20:09:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,
On Fri, Jul 21, 2017 at 11:42:46AM -0700, Cong Wang wrote:
> On Thu, Jul 20, 2017 at 8:23 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> > 2017-07-20 23:06 GMT+08:00 Hangbin Liu <liuhangbin@gmail.com>:
> >>> +++ b/net/ipv6/route.c
> >>> @@ -3637,12 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
> >>>                 dst = ip6_route_lookup(net, &fl6, 0);
> >>>
> >>>         rt = container_of(dst, struct rt6_info, dst);
> >>> -       if (rt->dst.error) {
> >>> -               err = rt->dst.error;
> >>> -               ip6_rt_put(rt);
> >>> -               goto errout;
> >>> -       }
> >>
> >> hmm... or instead of remove this check, should we check all the entry? Like
> >> if ((rt->dst.error && rt != net->ipv6.ip6_null_entry && rt !=
> >                                                     ^^ mistake here
> >> net->ipv6.ip6_blk_hole_entry) ||
> >>      rt == net->ipv6.ip6_null_entry )
> >
> > Sorry,  there should be no need to check ip6_null_entry since the
> > error is already
> > -ENETUNREACH. So how about
> 
> Hmm? All of these 3 entries have error set, right??
> So we should only check dst.error...

A question, since you have fixed the ip6_null_entry->rt6i_idev issue via

  ipv6: initialize route null entry in addrconf_init()
  ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
  ipv6: only call ip6_route_dev_notify() once for NETDEV_UNREGISTER
  ipv6: avoid unregistering inet6_dev for loopback

Do we still need this net->ipv6.ip6_null_entry check? How about remove all
the checks?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..b5e3fe0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3637,17 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
                dst = ip6_route_lookup(net, &fl6, 0);

        rt = container_of(dst, struct rt6_info, dst);
-       if (rt->dst.error) {
-               err = rt->dst.error;
-               ip6_rt_put(rt);
-               goto errout;
-       }
-
-       if (rt == net->ipv6.ip6_null_entry) {
-               err = rt->dst.error;
-               ip6_rt_put(rt);
-               goto errout;
-       }

        skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
        if (!skb) {


Before this patch:
+ ip netns exec client ip -6 route get 2003::1
RTNETLINK answers: Network is unreachable

After this patch:
+ ip netns exec client ip -6 route get 2003::1
unreachable 2003::1 dev lo table unspec proto kernel src 2001::1 metric 4294967295 error -101


Thanks
Hangbin
