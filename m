From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v3 02/10] Revert "lsm: Remove the socket_post_accept() hook"
Date: Fri, 06 May 2011 11:25:45 +0200
Message-ID: <87iptop4di.fsf@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<201105031802.34724.paul.moore@hp.com>
	<201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
	<201105051011.32845.paul.moore@hp.com>
	<201105060643.JBD90633.MOQJtSFFLFHOOV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201105060643.JBD90633.MOQJtSFFLFHOOV@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Fri, 6 May 2011 06:43:42 +0900")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Paul Moore wrote:
>> On Tuesday, May 03, 2011 10:28:24 PM Tetsuo Handa wrote:
>> > Paul Moore wrote:
>> > > On Tuesday, May 03, 2011 10:24:15 AM Samir Bellabes wrote:
>> > > > snet needs to reintroduce this hook, as it was designed to be: a hook
>> > > > for updating security informations on objects.
>> > > 
>> > > Looking at this and 5/10 again, it seems that you should be able to do
>> > > what you need with the sock_graft() hook.  Am I missing something?
>> > > 
>> > > My apologies if we've already discussed this approach previously ...
>> > 
>> > Second problem is that genlmsg_unicast() might return -EAGAIN because we
>> > can't sleep inside write_lock_bh()/write_unlock_bh().
>> 
>> Ah yes, the real problem.  I forgot that snet relied on a user space tool.  I 
>> tend to agree with others who have suggested this is not the right approach, 
>> but I understand why you want the post_accept() hook; thanks for reminding me.
>> 
> However, it sounds that Samir says genlmsg_unicast() failure is not fatal.

Actually, if the request to userspace is lost, no retransmission occurs.
there is a timeout to protect this case, and at the end of the tiemout,
a default verdict is apply. So no LSM decision is lost.

for the case of not checking return values, I fixed this in v4 with this
patch : 

commit 955d0a69c31684703dbeb1b15a462b06d4c79b52
Author: Samir Bellabes <sam@synack.fr>
Date:   Thu May 5 12:36:58 2011 +0200

    snet: fix returned value of snet_do_verdict() and
    snet_do_send_event()
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/security/snet/snet_hooks.c b/security/snet/snet_hooks.c
index 84ea5fc..5eb3848 100644
--- a/security/snet/snet_hooks.c
+++ b/security/snet/snet_hooks.c
@@ -67,23 +67,22 @@ static inline int snet_check_listeners(enum
snet_verdict *verdict)
        return 0;
 }
 
-static int snet_do_verdict(enum snet_verdict *verdict, struct snet_info
 *info)
+static void snet_do_verdict(enum snet_verdict *verdict, struct
snet_info *info)
 {
        if (info->verdict_id == 0)
-               return -1;
+               return;
        /* sending networking informations to userspace */
        if (snet_nl_send_event(info) == 0)
                /* waiting for userspace reply or timeout */
                *verdict = snet_verdict_wait(info->verdict_id);
        /* removing verdict */
        snet_verdict_remove(info->verdict_id);
-       return 0;
+       return;
 }
 
-static void snet_do_send_event(struct snet_info *info)
+static int snet_do_send_event(struct snet_info *info)
 {
-       snet_nl_send_event(info);
-       return;
+       return snet_nl_send_event(info);
 }
 
 /*

and introduce the statistics mecanism to count errors on all hooks
(statistics are available in /proc/snet/snet_stats)
for example:
                if (snet_do_send_event(&info) < 0)
                        SNET_STATS_INC(SNET_STATS_REG_ERROR,
                                       SNET_SOCKET_POST_ACCEPT);
                else
                        SNET_STATS_INC(SNET_STATS_REG_GRANT,
                                       SNET_SOCKET_POST_ACCEPT);

> Samir Bellabes wrote:
>> using snet_do_send_event() means that system is sending data to
>> userspace. the system is not waiting for a verdict from userspace.
>> 
>> If error occurs, we actually loose the information data.
>> I may be able to write a solution which try to send the data again, but
>> we need a exit solution for this loop (a number of try ?).
>
> If genlmsg_unicast() failure is not fatal, snet doesn't need the
> socket_post_accept hook. Samir, is genlmsg_unicast() failure fatal for snet?
> (Although, I'd like to ask for revival of the hook for TOMOYO anyway.)

the main argument for socket_post_accept is to known informations of the
remote inet.

from socket_accept(), we have no clue of who (inet->daddr and
inet->saddr) is connecting to the local service.
with socket_post_accept(), inet->daddr and inet->saddr are filled with
the true distant informations.

This informations is interesting for next security operations on the
socket. (we known with who we are talking to).


thanks,
sam
