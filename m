From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Mon, 20 Dec 2004 14:03:14 +0100
Message-ID: <20041220130314.GT17998@postel.suug.ch>
References: <20041219203050.GK17998@postel.suug.ch> <41C68CEF.3030803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41C68CEF.3030803@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41C68CEF.3030803@trash.net> 2004-12-20 09:27
> Thomas Graf wrote:
> >This patch is actually part of a patchset for 2.6.11 inclusion
> >but the memory corruption possibility might make it worth
> >for 2.6.10. It's not really dangerous since it requires
> >admin capabilities though.
> 
> There are lots of places where this is possible, just look
> at all the silly checks in the action code:
> 
>    sprintf(act_name, "%s", (char*)RTA_DATA(kind));
>    if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {

Agreed, also the recursive algorithms are vulnerable but
this doesn't mean we should just ignore it. I'm fine with
droping this for 2.6.10 and wait for my complete patchset.

> Why special-case indev ? Neither u32 nor fw make any attempt
> to clean up after errors in their init functions, so instead
> of fixing a single attribute they need to do proper cleanup,
> than we can just continue to validate indev when changing it.

As I said, the patch is part of a patchset which cleans up all
the init paths. I will introduce a new abstraction layer called
tcf_attrs which hides action/police configuration, removes all
the ifdefs without polluting the cls config data structures
and enforces the policy "change everything or nothing" to make
things consistent again. (They were once)

It basically works by having a struct tcf_attrs which ifdefs
tc_action, tcf_police and is empty if none of them are configured.
The classifiers include it in their private data and call
tcf_attrs_validate() and tcf_attrs_change() to validate respectively
commit the configuration requests or tcf_attrs_match() to match
them. The TLV mapping is done via tcf_attr_map which must be provided
by the classifiers:

static struct tcf_attr_map u32_map = {
	.action = TCA_U32_ACT,
	.police = TCA_U32_POLICE,
};

Speaking of it, would everyone agree to put indev matching into
the abstraction layer as well so it is available for all classifiers?
It doesn't cost us anything except a few iproute2 additions.

> I'm also against keeping all those printks when touching the
> code. Its ok when writing new code, but I don't see why this
> code, unlike everything else, needs to report errors in the
> ringbuffer instead of returning meaningful error codes.

I didn't want to change behaviour because there might be someone
checking for it, it's not that I'd like it.

> >+static inline void
> >+tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *id_tlv)
> >+{
> >+	memset(indev, 0, IFNAMSIZ);
> >+	memcpy(indev, RTA_DATA(id_tlv), RTA_PAYLOAD(id_tlv));
> >+	indev[IFNAMSIZ - 1] = '\0';
> >+}
> 
> And this should just use strlcpy.

No, RTA_DATA(id_tlv) is not guaranteed to be NUL terminated and internal
calls to strlen might crash. Even if it would be safe, I don't like
using str functions if NUL termination is not guaranteed.
