From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Tue, 17 Jul 2007 18:10:13 +0200
Message-ID: <469CE9E5.7040003@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090300080202010900060302"
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47936 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759751AbXGQQNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 12:13:12 -0400
In-Reply-To: <469BB50C.10203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090300080202010900060302
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Beschorner Daniel wrote:
>   
>>> I managed to reproduce a crash with ipcomp, will try to fix it later.
>>>       
>> Yes, I can confirm this.
>> After disabling IPComp the crashes went away.
>>     
>
>
> The crash happens in xfrm_bundle_ok when walking the bundle upwards
> following xfrm_dst->u.next. The loop should be stopped when
> xfrm_dst->u.next == first (the topmost xfrm_dst), but it points to
> NULL instead. I'm pretty sure the attached patch is responsible,
> it breaks XFRM's assumption that dst->next and xfrm_dst->u.next are
> the same pointer and xfrm_dst now shares the next pointer with
> rcu_head.next in struct dst_entry.
>
> Eric, could you look into this please?

I fixed it myself. Daniel, can you please test this patch?




--------------090300080202010900060302
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix crash introduced by struct dst_entry reordering

XFRM expects xfrm_dst->u.next to be same pointer as dst->next, which
was broken by the dst_entry reordering in commit 1e19e02c~, causing
an oops in xfrm_bundle_ok when walking the bundle upwards.

Kill xfrm_dst->u.next and change the only user to use dst->next instead.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 20c2fee8cc562817f11752e1d87350d5994fa098
tree f42318b847e962aa637136e94722a688c231111a
parent 308ac1b6249226730b70fcf7c13a289c27ce2bf3
author Patrick McHardy <kaber@trash.net> Tue, 17 Jul 2007 18:11:29 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 17 Jul 2007 18:11:29 +0200

 include/net/xfrm.h     |    1 -
 net/xfrm/xfrm_policy.c |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ae959e9..a5f80bf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -585,7 +585,6 @@ static inline int xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ct
 struct xfrm_dst
 {
 	union {
-		struct xfrm_dst		*next;
 		struct dst_entry	dst;
 		struct rtable		rt;
 		struct rt6_info		rt6;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 157bfbd..b48f06f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2141,7 +2141,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		if (last == first)
 			break;
 
-		last = last->u.next;
+		last = (struct xfrm_dst *)last->u.dst.next;
 		last->child_mtu_cached = mtu;
 	}
 

--------------090300080202010900060302--
