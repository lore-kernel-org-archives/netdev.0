From: "Manish Katiyar" <mkatiyar@gmail.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/netlabel/netlabel_addrlist.c
Date: Wed, 29 Oct 2008 23:57:44 +0530
Message-ID: <ea11fea30810291127h3d5ade4btcd3b327863e7b210@mail.gmail.com>
References: <ea11fea30810290106u3f92268q62226da65db6f6a4@mail.gmail.com>
	 <200810290949.09108.paul.moore@hp.com>
	 <ea11fea30810290818p2ae6c11eo5e38baf631867fb1@mail.gmail.com>
	 <200810291135.25056.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mkatiyar@gmail.com
To: "Paul Moore" <paul.moore@hp.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:45487 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbYJ2S1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:27:47 -0400
In-Reply-To: <200810291135.25056.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 9:05 PM, Paul Moore <paul.moore@hp.com> wrote:
> On Wednesday 29 October 2008 11:18:36 am you wrote:
>> On Wed, Oct 29, 2008 at 7:19 PM, Paul Moore <paul.moore@hp.com> wrote:
>> > On Wednesday 29 October 2008 4:06:09 am Manish Katiyar wrote:
>> >> Below patch fixes the following warning.
>> >> net/netlabel/netlabel_addrlist.c:335: warning: unused variable
>> >> 'dir' net/netlabel/netlabel_addrlist.c:369: warning: unused
>> >> variable 'dir'
>> >>
>> >>
>> >> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
>> >
>> > Hi Manish,
>> >
>> > Good catch, I ran compile tests with different
>> > SECURITY/NETLABEL/IPV6 options enabled/disabled but forgot about
>> > AUDIT.  I appreciate your help finding this and submitting a
>> > possible solution but I think the better approach would be to
>> > conditionally compile out the
>> > netlbl_af{4,6}list_audit_addr() functions similarly to what we do
>> > with several of the NetLabel kernel API functions in
>> > include/net/netlabel.h, see netlbl_enabled() for a simple example.
>>
>> Hi Paul,
>>
>> Thanks a lot. I didn't understand your suggestion, but this is also
>> the first time I am looking in net directory :-).
>
> There is a first time for everything :)
>
>> Even if you compile
>> netlbl_af{4,6}list_audit_add conditionally based on CONFIG_IPV6 and
>> others, you still need to have CONFIG_AUDIT for audit_log_format().
>> Isn't it ??
>
> Yes, but the idea is to conditionally compile the
> netlbl_af{4,6}list_audit_add() functions based on CONFIG_AUDIT.  Below
> is a simple example using myfunc():
>
> In the source file you define the function:
>
>  void myfunc(int myarg)
>  {
>        /* bunch of audit stuff */
>  }
>
> In the header file you have a conditional prototype declaration:
>
>  #ifdef CONFIG_AUDIT
>  void myfunc(int myarg);
>  #else
>  static inline void myfunc(int myarg)
>  {
>        return;
>  }
>  #endif
>
> This way the code compiles correctly regardless of if CONFIG_AUDIT is
> defined and has the benefit of not including unnecessary code in the
> kernel binary.

Hi Paul,

Does this look better ?? Appreciate your help. Patch compile tested.

Enable netlabel auditing functions only when CONFIG_AUDIT is set

Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
---
 net/netlabel/netlabel_addrlist.c |    2 ++
 net/netlabel/netlabel_addrlist.h |   20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index b0925a3..830afef 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -311,6 +311,7 @@ struct netlbl_af6list *netlbl_af6list_remove(const
struct in6_addr *addr,
 }
 #endif /* IPv6 */

+#ifdef CONFIG_AUDIT
 /*
  * Audit Helper Functions
  */
@@ -386,3 +387,4 @@ void netlbl_af6list_audit_addr(struct audit_buffer
*audit_buf,
 	}
 }
 #endif /* IPv6 */
+#endif /* CONFIG_AUDIT */
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index 0242bea..7fa730a 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -120,9 +120,18 @@ struct netlbl_af4list *netlbl_af4list_search(__be32 addr,
 struct netlbl_af4list *netlbl_af4list_search_exact(__be32 addr,
 						   __be32 mask,
 						   struct list_head *head);
+
+#ifdef CONFIG_AUDIT
 void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
 			       int src, const char *dev,
 			       __be32 addr, __be32 mask);
+#else
+static inline void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
+			       int src, const char *dev,
+			       __be32 addr, __be32 mask) {
+	return;
+}
+#endif

 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

@@ -179,11 +188,22 @@ struct netlbl_af6list
*netlbl_af6list_search(const struct in6_addr *addr,
 struct netlbl_af6list *netlbl_af6list_search_exact(const struct in6_addr *addr,
 						   const struct in6_addr *mask,
 						   struct list_head *head);
+
+#ifdef CONFIG_AUDIT
 void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
 			       int src,
 			       const char *dev,
 			       const struct in6_addr *addr,
 			       const struct in6_addr *mask);
+#else
+static inline void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
+			       int src,
+			       const char *dev,
+			       const struct in6_addr *addr,
+			       const struct in6_addr *mask) {
+	return;
+}
+#endif
 #endif /* IPV6 */

 #endif
-- 
1.5.4.3

Thanks -
Manish


>
>> > If you have the time to revise this patch that would be great, just
>> > CC me on the posting and I'll look it over.
>>
>> Since this is not my area of expertise, I would rather not like to
>> introduce more bugs in kernel. But yes I can try my best to learn and
>> try to fix it if you are willing to lend a helping hand (which might
>> be iterative and irritating for you due to my stupid questions).
>
> I'm more than happy to help but all I ask is that we keep the discussion
> on the mailing lists so that others could benefit from the discussion.
> However, if this isn't something you are comfortable with just let me
> know.
>
> --
> paul moore
> linux @ hp
>
