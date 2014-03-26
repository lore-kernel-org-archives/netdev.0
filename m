From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: Re: [PATCH net] ipv6: If a public address is deleted then also delete
 all temporary addresses still referring to it
Date: Wed, 26 Mar 2014 21:27:21 +0100
Message-ID: <53333829.2000806@web.de>
References: <5328B0B0.7070305@web.de> <20140319202123.GH12291@order.stressinduktion.org> <532A096C.8030200@web.de> <20140319224121.GI12291@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:61916 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755521AbaCZU3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 16:29:25 -0400
In-Reply-To: <20140319224121.GI12291@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.03.2014 23:41, schrieb Hannes Frederic Sowa:
> On Wed, Mar 19, 2014 at 10:17:32PM +0100, Heiner Kallweit wrote:
>> Am 19.03.2014 21:21, schrieb Hannes Frederic Sowa:
>>> On Tue, Mar 18, 2014 at 09:46:40PM +0100, Heiner Kallweit wrote:
>>>> If a public address is deleted by an external trigger (e.g. via inet6_rtm_deladdr) then temporary
>>>> addresses still referring to it may remain. Happened here when the WiFi link broke and netifd
>>>> deleted the public address. Once the link was back and prefix_rcv created new public addresses
>>>> ipv6_create_tempaddr complained that the temporary address already existed.
>>> Which error was it specifically?
>>>
>>>> IMHO no temporary address should live longer than its parent, especially because ifpub of the
>>>> temporary address still points to the then deleted public address otherwise.
>>> Reference counting will take care of that.
>>>
>>>> Therefore delete all related temporary addresses before a public address is deleted in inet6_addr_del
>>>> which is called by inet6_rtm_del.
>>> I am a bit concerend with backward compatibility here.
>>>
>>>> Also ensure in ipv6_del_addr that no temporary address lives longer than its parent.
>>> I currently don't see a problem with that.
>>>
>>> Greetings,
>>>
>>>   Hannes
>>>
>>>
>> The specific error was "retry temporary address regeneration" caused by ipv6_add_addr returning EEXIST.
>>
>> First question is whether it's correct that in case of link loss the public address is deleted but not the temporary addresses.
>> I don't think it's correct.
> The kernel doesn't delete any addresses in case of link loss. netifd must
> have done so. In this case netifd should have flushed all addresses from
> the prefix.
>
> Sure, this is racy and the error therefore looks justified for me.
>
>> If it's not correct then the question is who's reponsibility it is to delete temporary addresses if the parent public address is deleted.
> In my opinion those addresses are simple standalone addresses. The link
> to the public addresses is just for management purposes and should be
> hidden from user space.
>
> So I would be ok, if we enhance the error case a bit, maybe reparent the
> old temporary address, drop them and silently generate them anew or only
> update prefix information from the new received prefix information. This
> should happen without disturbing TCP connections etc. I think this
> already works, but I don't know if it is worth the effort.
>
>> My solution was to do it in the kernel but this might not be the best / correct approach.
>> Would you prefer that userspace / netifd take care to also delete the temporary addresses?
> Yes, I would prefer that.
>
>> Last but not least the question is whether the kernel should care in general about the situation that a public address is deleted and orphaned
>> temporary addresses are left behind.
> I think that we should think of temporary addresses as stand-alone
> (IFA_F_MANAGETEMPADDR is a different story).
>
> Btw. there was already lots of discussions whether automatically drop addresses
> of an interface in case of link-loss, you can read the IMHO most relevant here:
> <http://markmail.org/thread/wcb6f6lcuyfuli7b>
>
> Greetings,
>
>   Hannes

I spent some thoughts on this topic and it seems to me that deleting a temporary address from user space will break TCP connections most of the time
as the newly created temporary address will be different from the old one.
Setting a temporary address to deprecated is also not possible from user space currently as netlink RTM_NEWADDR doesn't allow to modify the IFA_F_DEPRECATED flag:

/* We ignore other flags so far. */
	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
		     IFA_F_NOPREFIXROUTE;

Having said that your suggestion seems to be the most appropriate way to tackle the issue:

"So I would be ok, if we enhance the error case a bit, maybe reparent the
old temporary address, drop them and silently generate them anew or only
update prefix information from the new received prefix information. This
should happen without disturbing TCP connections etc. I think this
already works, but I don't know if it is worth the effort."

The following patch works fine for me, I'd appreciate if you could have a look at it.

Rgds, Heiner

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 344e972..7cc3dae 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2063,8 +2063,23 @@ static void manage_tempaddrs(struct inet6_dev *idev,
     list_for_each_entry(ift, &idev->tempaddr_list, tmp_list) {
         int age, max_valid, max_prefered;
 
-        if (ifp != ift->ifpub)
-            continue;
+        spin_lock(&ift->lock);
+        if (ifp != ift->ifpub) {
+            /* reparent if orphaned temporary addresses with same prefix is found */
+            if(ift->prefix_len == ifp->prefix_len && ipv6_prefix_equal(&ift->addr,&ifp->addr,ift->prefix_len)) {
+                in6_ifa_hold(ifp);
+                in6_ifa_put(ift->ifpub);
+                ift->ifpub = ifp;
+                spin_unlock(&ift->lock);
+                create = false;
+                pr_info("%s: reparent orphaned temporary address\n", __func__);
+            } else {
+                spin_unlock(&ift->lock);
+                continue;
+            }
+        } else {
+            spin_unlock(&ift->lock);
+        }
 
         /* RFC 4941 section 3.3:
          * If a received option will extend the lifetime of a public
