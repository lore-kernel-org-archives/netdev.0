From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/netlink: global-out-of-bounds in genl_family_rcv_msg/validate_nla
Date: Wed, 2 Nov 2016 22:25:29 -0700
Message-ID: <CAM_iQpWBoEhaLfCYPaStZ-U8s-i5h9fmaG9JCW-q7QfjntfEOA@mail.gmail.com>
References: <CAAeHK+xm5_n-Ep2d4YEq=Yx=f5M2NpV-So0o7811LUk+pLr+rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Florian Westphal <fw@strlen.de>,
        netdev <netdev@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xm5_n-Ep2d4YEq=Yx=f5M2NpV-So0o7811LUk+pLr+rg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 2, 2016 at 5:25 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while running the syzkaller fuzzer:
>
> ==================================================================
> BUG: KASAN: global-out-of-bounds in validate_nla+0x49b/0x4e0 at addr
> ffffffff8407e3ac
> Read of size 2 by task a.out/3877
> Address belongs to variable[<        none        >]
> cgroupstats_cmd_get_policy+0xc/0x40 ??:?

Seems taskstats doesn't use genetlink correctly, CGROUPSTATS_CMD_ATTR_FD
is not within 0~TASKSTATS_CMD_ATTR_MAX.

I guess we need the following patch, but it certainly breaks user-space... :-/

diff --git a/include/uapi/linux/cgroupstats.h b/include/uapi/linux/cgroupstats.h
index 3753c33..b5c120c 100644
--- a/include/uapi/linux/cgroupstats.h
+++ b/include/uapi/linux/cgroupstats.h
@@ -61,7 +61,7 @@ enum {
 #define CGROUPSTATS_TYPE_MAX (__CGROUPSTATS_TYPE_MAX - 1)

 enum {
-       CGROUPSTATS_CMD_ATTR_UNSPEC = 0,
+       CGROUPSTATS_CMD_ATTR_UNSPEC = __TASKSTATS_CMD_ATTR_MAX,
        CGROUPSTATS_CMD_ATTR_FD,
        __CGROUPSTATS_CMD_ATTR_MAX,
 };
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index b3f05ee..78502b0 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -45,7 +45,7 @@ static struct genl_family family = {
        .id             = GENL_ID_GENERATE,
        .name           = TASKSTATS_GENL_NAME,
        .version        = TASKSTATS_GENL_VERSION,
-       .maxattr        = TASKSTATS_CMD_ATTR_MAX,
+       .maxattr        = CGROUPSTATS_CMD_ATTR_MAX,
 };

 static const struct nla_policy
taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1] = {
