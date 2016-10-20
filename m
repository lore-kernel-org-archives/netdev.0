From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Thu, 20 Oct 2016 15:07:35 -0400
Message-ID: <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:35532 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcJTTHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 15:07:38 -0400
Received: by mail-vk0-f67.google.com with SMTP id 130so3572526vkg.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 12:07:37 -0700 (PDT)
In-Reply-To: <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 2:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Oct 20, 2016 at 7:58 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>> On 10/20/2016 02:52 AM, Cong Wang wrote:
>>> A kernel warning inside __local_bh_enable_ip() was reported by people
>>> running SELinux, this is caused due to some SELinux functions
>>> (indirectly) call peernet2id() with IRQ disabled in process context,
>>> when we re-enable BH with IRQ disabled kernel complains. Shut up this
>>> warning by saving IRQ context in peernet2id(), BH is still implicitly
>>> disabled.
>>
>> Not sure this suffices; kill_fasync() -> send_sigio() ->
>> send_sigio_to_task() -> sigio_perm() -> security_file_send_sigiotask()
>> -> selinux_file_send_sigiotask() -> ... -> audit_log() -> ... ->
>> peernet2id()
>
> Oh, this is a new one. kill_fasync() is called in IRQ handler, so we actually
> do multicast in IRQ context.... It makes no sense, netlink multicast could
> be very expensive if we have many listeners.

I'm sure there are a few others I don't know about, but I believe the
only commonly used audit multicast listener is systemd.

> I am Cc'ing Richard who added that multicast in audit_log_end(). It seems
> not easy to just move the multicast to a workqueue, since the skb is copied
> from audit_buffer which is freed immediately after that, probably need another
> queue like audit_skb_queue.

This approach would double the queue size which is something I want to
avoid.  I would suggest sticking with a single queue and dealing with
the netlink message link fixup and multicast send in the existing
netlink unicast thread; basically we would just be moving the
multicast code from audit_log_end() into kauditd_thread().  This is
the same approach I mentioned earlier off-list.

However, that isn't something I want to mess with as a regression fix,
mostly because I really want to see this regression gone by -rc2 as it
is making SELinux testing a real pain.  If the patch posted at the top
of this thread isn't a suitable fix, we really should revert the
original patch.

-- 
paul moore
www.paul-moore.com
