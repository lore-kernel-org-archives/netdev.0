From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Date: Sun, 30 Oct 2016 06:20:01 -0700
Message-ID: <1477833601.7065.297.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
         <CAM_iQpX_xw35MUyd9aON5U=HmUoRafeoOF+_vSTHGYnrXd-CHg@mail.gmail.com>
         <CAAeHK+y9ENvGzJEQtRy_5DEzCfhGEYXR5CPpgwXy_FoOtFUf3Q@mail.gmail.com>
         <1477762981.7065.272.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+x6+CU+1KJNOpnoyyZoqH7_dcrWFVGU1KrJYVwJSzdxPg@mail.gmail.com>
         <1477764328.7065.284.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+z2mqZCsZpPP_hNY2-bt_-WEU9rFmOd=jcWSBmVPDS_rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32965 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbcJ3NUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 09:20:05 -0400
In-Reply-To: <CAAeHK+z2mqZCsZpPP_hNY2-bt_-WEU9rFmOd=jcWSBmVPDS_rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-10-30 at 05:41 +0100, Andrey Konovalov wrote:
> Sorry, the warning is still there.
> 
> I'm not sure adding sched_annotate_sleep() does anything, since it's
> defined as (in case CONFIG_DEBUG_ATOMIC_SLEEP is not set):
> # define sched_annotate_sleep() do { } while (0)

Thanks again for testing.

But you do have CONFIG_DEBUG_ATOMIC_SLEEP set, which triggers a check in
__might_sleep() :

WARN_ONCE(current->state != TASK_RUNNING && current->task_state_change,

Relevant commit is 00845eb968ead28007338b2bb852b8beef816583
("sched: don't cause task state changes in nested sleep debugging")

Another relevant commit was 26cabd31259ba43f68026ce3f62b78094124333f
("sched, net: Clean up sk_wait_event() vs. might_sleep()") 

Before release_sock() could process the backlog in process context, only
lock_sock() could trigger the issue, so my fix at that time was commit
cb7cf8a33ff73cf638481d1edf883d8968f934f8 ("inet: Clean up
inet_csk_wait_for_connect() vs. might_sleep()")

I guess we need something else now, because the following :

static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
{
        DEFINE_WAIT(wait);
        long remaining;

        prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
        sk->sk_write_pending++;
        release_sock(sk);
	...


can now process the socket backlog in process context from
release_sock(), so all GFP_KERNEL allocations might barf because of
TASK_INTERRUPTIBLE being used at that point.

sk_wait_event() probably also needs a fix.

Peter, any idea how this can be done ?

Thanks !
