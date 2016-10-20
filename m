From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Thu, 20 Oct 2016 11:29:11 -0700
Message-ID: <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com> <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Paul Moore <paul@paul-moore.com>,
        Richard Guy Briggs <rgb@redhat.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33942 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933076AbcJTS3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:29:32 -0400
Received: by mail-it0-f65.google.com with SMTP id e203so7371045itc.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:29:32 -0700 (PDT)
In-Reply-To: <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 7:58 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
> On 10/20/2016 02:52 AM, Cong Wang wrote:
>> A kernel warning inside __local_bh_enable_ip() was reported by people
>> running SELinux, this is caused due to some SELinux functions
>> (indirectly) call peernet2id() with IRQ disabled in process context,
>> when we re-enable BH with IRQ disabled kernel complains. Shut up this
>> warning by saving IRQ context in peernet2id(), BH is still implicitly
>> disabled.
>
> Not sure this suffices; kill_fasync() -> send_sigio() ->
> send_sigio_to_task() -> sigio_perm() -> security_file_send_sigiotask()
> -> selinux_file_send_sigiotask() -> ... -> audit_log() -> ... ->
> peernet2id()

Oh, this is a new one. kill_fasync() is called in IRQ handler, so we actually
do multicast in IRQ context.... It makes no sense, netlink multicast could
be very expensive if we have many listeners.

I am Cc'ing Richard who added that multicast in audit_log_end(). It seems
not easy to just move the multicast to a workqueue, since the skb is copied
from audit_buffer which is freed immediately after that, probably need another
queue like audit_skb_queue.
