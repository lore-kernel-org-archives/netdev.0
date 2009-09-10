From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Wed, 09 Sep 2009 20:41:32 -0400
Message-ID: <4AA84B3C.4000401@hp.com>
References: <4AA1C0FF.4030109@hp.com> <1252418247.5827.8.camel@fnki-nb00130>	 <4AA675D4.8030406@hp.com> <1252424623.5827.14.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: david Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:3128 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbZIJAmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 20:42:06 -0400
In-Reply-To: <1252424623.5827.14.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
> On Tue, 2009-09-08 at 11:18 -0400, Brian Haley wrote:
>> Jens Rosenboom wrote:
>>>> --- a/net/ipv6/addrconf.c
>>>> +++ b/net/ipv6/addrconf.c
>>>> @@ -1376,7 +1376,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
>>>>  	if (ifp->flags&IFA_F_PERMANENT) {
>>>>  		spin_lock_bh(&ifp->lock);
>>>>  		addrconf_del_timer(ifp);
>>>> -		ifp->flags |= IFA_F_TENTATIVE;
>>>> +		ifp->flags |= IFA_F_DADFAILED;
>>> I think you still have to set IFA_F_TENTATIVE here, too, otherwise
>>> ipv6_dev_get_saddr() will use this address. 		
>> The tentative bit is still set from when this address was added back
>> in ipv6_add_addr() from what I can tell, re-setting it here is actually
>> unnecessary.  At least /sbin/ip was still showing it set during my
>> testing.
> 
> There is the possibility of a race when the dad_timer expires at the
> same time the NA triggering DAD failure is received. There isn't a big
> chance to see that during real world testing, though.

Ok, how does this look?  I changed it to set the tentative flag as it did
before, plus clear the dad_failed flag if the device got restarted,
triggering DAD to happen again for any tentative address, that was an
oversight on my part.

I'd still like to know if using this last ifa_flag is going to be an issue,
I actually finished a similar patch that uses a new IFA_ADDRFLAGS structure
to pass in/out this additional info.

-Brian


diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index a60c821..fd97404 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -41,6 +41,7 @@ enum
 
 #define	IFA_F_NODAD		0x02
 #define IFA_F_OPTIMISTIC	0x04
+#define IFA_F_DADFAILED		0x08
 #define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 43b3c9f..c9b3690 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1371,12 +1371,14 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 
 /* Gets referenced address, destroys ifaddr */
 
-static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
+static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 {
 	if (ifp->flags&IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
 		addrconf_del_timer(ifp);
 		ifp->flags |= IFA_F_TENTATIVE;
+		if (dad_failed)
+			ifp->flags |= IFA_F_DADFAILED;
 		spin_unlock_bh(&ifp->lock);
 		in6_ifa_put(ifp);
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1422,7 +1424,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		}
 	}
 
-	addrconf_dad_stop(ifp);
+	addrconf_dad_stop(ifp, 1);
 }
 
 /* Join to solicited addr multicast group. */
@@ -2778,7 +2780,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
-		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
@@ -2795,7 +2797,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 		 * - otherwise, kill it.
 		 */
 		in6_ifa_hold(ifp);
-		addrconf_dad_stop(ifp);
+		addrconf_dad_stop(ifp, 0);
 		return;
 	}
 
@@ -2829,7 +2831,7 @@ static void addrconf_dad_timer(unsigned long data)
 		 * DAD was successful
 		 */
 
-		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
