From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Mon, 18 Oct 2004 00:26:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4172F1AB.4020305@trash.net>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070707010003070307020000"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041017212317.GA28615@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070707010003070307020000
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:

>On Sun, Oct 17, 2004 at 05:48:11PM +0200, Patrick McHardy wrote:
>  
>
>>currently forwarded packets from a tunnel mode SA are checked
>>in ip_forward/ip6_forward against the XFRM_POLICY_FWD policy
>>list. Neither racoon nor pluto generate a policy for
>>IPSEC_DIR_FWD, so the checks are performed against an empty
>>    
>>
>
>Actually I made damn sure that pluto does generate rules for
>IPSEC_DIR_FWD after discussing it with Alexey :) Search for
>XFRM_POLICY_FWD in openswan/programs/pluto.
>  
>
Thanks, I didn't know pluto uses the xfrm_user interface, so
I only looked for pfkey symbolic names. So it seems only racoon
needs to be fixed. I think we should apply the attached patch
to make xfrm_policy_check reject packets decapsulated by IPsec
without a policy for this direction, so people will notice
something is wrong. It also prevents skipping checks against the
socket policy if there is an empty policy list .. or am I missing
something ?

Regards
Patrick


--------------070707010003070307020000
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/18 00:09:08+02:00 kaber@coreworks.de 
#   [XFRM]: Fix invalid optimization in xfrm_policy_check
#   
#   By skipping policy checks when the policy list is empty we
#   allow packets decapsulated by IPsec without a policy and
#   miss checking against socket policies.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/xfrm.h
#   2004/10/18 00:08:14+02:00 kaber@coreworks.de +1 -1
#   [XFRM]: Fix invalid optimization in xfrm_policy_check
#   
#   By skipping policy checks when the policy list is empty we
#   allow packets decapsulated by IPsec without a policy and
#   miss checking against socket policies.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-10-18 00:15:18 +02:00
+++ b/include/net/xfrm.h	2004-10-18 00:15:18 +02:00
@@ -601,7 +601,7 @@
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, dir, skb, family);
 		
-	return	!xfrm_policy_list[dir] ||
+	return	((!sk || !sk->sk_policy[dir]) && !xfrm_policy_list[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, dir, skb, family);
 }

--------------070707010003070307020000--
