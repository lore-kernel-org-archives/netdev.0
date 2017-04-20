From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 13:35:40 +0200
Message-ID: <20170420113540.GC1886@nanopsycho.orion>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
 <705a4d67-4a81-113f-e22a-0ca0bb6cf1eb@mojatatu.com>
 <20170419131323.GE3357@nanopsycho.orion>
 <e2a1e201-4830-e600-e668-91f83bcc9b32@mojatatu.com>
 <20170419155400.GH3357@nanopsycho.orion>
 <56488055-1f4b-ee10-2357-5ce80f1fbc50@mojatatu.com>
 <20170419161736.GJ3357@nanopsycho.orion>
 <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35257 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753646AbdDTLfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 07:35:44 -0400
Received: by mail-wr0-f194.google.com with SMTP id l44so7128353wrc.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 04:35:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 20, 2017 at 12:42:55PM CEST, jhs@mojatatu.com wrote:
>On 17-04-19 12:17 PM, Jiri Pirko wrote:
>> Wed, Apr 19, 2017 at 06:07:48PM CEST, jhs@mojatatu.com wrote:
>> > On 17-04-19 11:54 AM, Jiri Pirko wrote:
>> > > Wed, Apr 19, 2017 at 05:37:15PM CEST, jhs@mojatatu.com wrote:
>> > > > On 17-04-19 09:13 AM, Jiri Pirko wrote:
>> > > > > Wed, Apr 19, 2017 at 03:03:59PM CEST, jhs@mojatatu.com wrote:
>> > > > > > On 17-04-19 08:36 AM, Jiri Pirko wrote:
>> > > > > > > Wed, Apr 19, 2017 at 01:57:29PM CEST, jhs@mojatatu.com wrote:
>> > > > > > > > From: Jamal Hadi Salim <jhs@mojatatu.com>
>> > > > > > 
>> > > > > > > > include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++++--
>> > > > > > > > net/sched/act_api.c            | 43 ++++++++++++++++++++++++++++++++----------
>> > > > > > > > 3 files changed, 53 insertions(+), 12 deletions(-)
>> > > > 
>> > > > > > > > +#define TCAA_MAX (__TCAA_MAX - 1)
>> > > > > > > > #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>> > > > > > > > #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>> > > > > > > > -#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>> > > > > > > > -#define TCAA_MAX 1
>> > > > > > > > +#define TCA_ACT_TAB TCAA_ACT_TAB
>> > > > > > > 
>> > > > > > > This is mess. What does "TCAA" stand for?
>> > > > > > 
>> > > > > > TC Actions Attributes.  What would you call it? I could have
>> > > > > > called it TCA_ROOT etc. But maybe a comment to just call it
>> > > > > > TC Actions Attributes would be enough?
>> > > > > 
>> > > > > TCA_DUMP_X
>> > > > > 
>> > > > > it is only for dumping. Naming it "attribute" seems weird. Same as if
>> > > > > you have: int variable_something;
>> > > > > 
>> > > > 
>> > > > Jiri, this is not just for dumping. We are describing high level
>> > > > attributes for tc actions.
>> > > 
>> > > This is already present:
>> > > enum {
>> > >         TCA_ACT_UNSPEC,
>> > >         TCA_ACT_KIND,
>> > >         TCA_ACT_OPTIONS,
>> > >         TCA_ACT_INDEX,
>> > >         TCA_ACT_STATS,
>> > >         TCA_ACT_PAD,
>> > >         TCA_ACT_COOKIE,
>> > >         __TCA_ACT_MAX
>> > > };
>> > > 
>> > > This is nested inside the dump message (TCAA_MAX, TCA_ACT_TAB)
>> > > 
>> > > Looks like you are mixing these 2.
>> > > 
>> > 
>> > No - That space is per action. The space i am defining is
>> > above that in the the hierarchy. There used to be only
>> > one attribute there (TCA_ACT_TAB) and now we are making
>> > it more generic.
>> 
>> Right. That's what I say. And that higher level is used only for
>> dumping. That's why I suggested TCA_ACT_DUMP prefix.
>> 
>
>DUMP is not right. _TAB is used for SET/DEL as well.
>why dont we leave this alone so we can progress?
>You can submit changes later if it bothers you still.

Ha. So the current code is wrong, I see it now. Following is needed:

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 82b1d48..c432b22 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1005,7 +1005,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
 			  extack);
 	if (ret < 0)
 		return ret;

You confused me squashing the change to this patch.

Ok, so the name could be:
TCA_ACTS_*
?
I believe it is crucial to figure this out right now. TC UAPI is in deep
mess already, no need to push it even more.


>
>> 
>> > 
>> > > 
>> > > 
>> > 
>> > > > It is a _lot_ of code to change! Note:
>> > > > This is all the UAPI visible code (the same coding style for 20 years).
>> > > > I am worried about this part.
>> > > 
>> > > We'll see. Lets do it in a sensitive way, in steps. But for new things,
>> > > I think it is good not to stick with old and outlived habits.
>> > > 
>> > > 
>> > 
>> > I know you have the muscle to get it done - so fine, i will start
>> > with this one change.
>> > 
>> > > 
>> > > Netlink is TLV, should be used as TLV. I don't see how you can run out
>> > > any space. You tend to use Netlink in some weird hybrid mode, with only
>> > > argument being space. I think that couple of bytes wasted is not
>> > > a problem at all...
>> > > 
>> > 
>> > You are not making sense to me still.
>> > What you describe as "a couple of bytes" adds up when you have
>> > a large number of objects. I am trying to cut down on data back
>> > and forth from user/kernel and a bitmap is a well understood entity.
>> 
>> The attributes in question are per-message, not per-object
>> 
>> 
>> > 
>> > Even if i did use a TLV - when i am representing flags which require one
>> > bit each - it makes sense to use a bitmask encapsulated in a TLV. Not
>> > to waste a TLV per bit.
>> 
>> That is the only correct way. For example, in future the kernel may
>> report in extended ack that it does not support some specific attribute
>> user passed. If you pack it all in one attr, that would not be possible.
>> Also, what prevents user from passing random data on bit flag positions
>> that you are not using? Current kernel would ignore it. Next kernel will
>> do something different according to the flag bit. That is UAPI break.
>> Essentialy the same thing what DaveM said about the struct. You have to
>> define this completely, at the beginning, not possible to use the unused
>> bits for other things in the future.
>> 
>
>
>They are not the same issue Jiri. We have used bitmasks fine on netlink

Howcome they are not the same? I'm pretty certain they are.


>message for a millenia. Nobody sets garbage on a bitmask they are not
>supposed to touch. The struct padding thing is a shame the way it
>turned out - now netlink can no longer have a claim to be a (good)
>wire protocol.
>Other thing: I know you feel strongly about this but I dont agree that
>everything has to be a TLV and in no way, as a matter of principle, you are
>going to convince me  (even when the cows come home) that I have to
>use 64 bits to carry a single bit just so I can use TLVs.

Then I guess we have to agree to disagree. I believe that your approach
is wrong and will break users in future when you add even a single flag.
Argument that "we are doing this for ages-therefore it is correct" has
simply 0 value.
