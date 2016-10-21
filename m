From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 12:19:52 -0400
Message-ID: <CAHC9VhQWWDHnQGv+feXZ_CDrkftuRkKLtKvXkpN0pqh6e6hMPQ@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com> <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33982 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935179AbcJUQTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 12:19:54 -0400
Received: by mail-vk0-f65.google.com with SMTP id 2so5033723vkb.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 09:19:54 -0700 (PDT)
In-Reply-To: <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 7:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Oct 20, 2016 at 12:07 PM, Paul Moore <paul@paul-moore.com> wrote:
>> On Thu, Oct 20, 2016 at 2:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Thu, Oct 20, 2016 at 7:58 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>>>> On 10/20/2016 02:52 AM, Cong Wang wrote:
>>>>> A kernel warning inside __local_bh_enable_ip() was reported by people
>>>>> running SELinux, this is caused due to some SELinux functions
>>>>> (indirectly) call peernet2id() with IRQ disabled in process context,
>>>>> when we re-enable BH with IRQ disabled kernel complains. Shut up this
>>>>> warning by saving IRQ context in peernet2id(), BH is still implicitly
>>>>> disabled.
>>>>
>>>> Not sure this suffices; kill_fasync() -> send_sigio() ->
>>>> send_sigio_to_task() -> sigio_perm() -> security_file_send_sigiotask()
>>>> -> selinux_file_send_sigiotask() -> ... -> audit_log() -> ... ->
>>>> peernet2id()
>>>
>>> Oh, this is a new one. kill_fasync() is called in IRQ handler, so we actually
>>> do multicast in IRQ context.... It makes no sense, netlink multicast could
>>> be very expensive if we have many listeners.
>>
>> I'm sure there are a few others I don't know about, but I believe the
>> only commonly used audit multicast listener is systemd.
>
> But user-space is free to listen to this group, right? If so this is just open
> for a potential DDOS attack.

Listeners are required to have CAP_AUDIT_READ.

>>> I am Cc'ing Richard who added that multicast in audit_log_end(). It seems
>>> not easy to just move the multicast to a workqueue, since the skb is copied
>>> from audit_buffer which is freed immediately after that, probably need another
>>> queue like audit_skb_queue.
>>
>> This approach would double the queue size which is something I want to
>> avoid.  I would suggest sticking with a single queue and dealing with
>> the netlink message link fixup and multicast send in the existing
>> netlink unicast thread; basically we would just be moving the
>> multicast code from audit_log_end() into kauditd_thread().  This is
>> the same approach I mentioned earlier off-list.
>
> This is what I did in the follow up patch. I attach the updated version
> in this email for you to review ...

I think there is still some confusion.  The second patch you posted
still has two queues with potentially duplicated (minus the length
tweaks) skbs.

What I am talking about is queuing the skb in audit_log_end(), without
any modification, waking up the kauditd_thread, and then letting the
kauditd_thread() function do both the netlink multicast and unicast
sends, complete with the skb_copy() and length tweaks.  This way we
only queue one copy of the skb.  To help make this more clear, I'll
work up a patch and CC you.

However, let me say this one more time: this is *NOT* a change I want
to make during the -rcX cycle, this is a change that we should do for
-next and submit during the next merge window after is has been tested
and soaked in linux-next.  Given where we are at right now - it's
Friday and I expect -rc2 on Sunday - I think the best course of action
is to revert the original patch and move on.  I'm going to do that now
and I'll submit it to netdev as soon as I've done some basic sanity
checks.

> ... I still can't make selinux-testsuites working
> on my Fedora even though I have SELinux=enforcing, anyhow I don't
> see any kernel warning in my dmesg at least.

Stephen already responded and I agree with him, it looks like
something might be off with your kernel config.  Everything works
correctly for me with upstream and Fedora Rawhide kernels.

>> However, that isn't something I want to mess with as a regression fix,
>> mostly because I really want to see this regression gone by -rc2 as it
>> is making SELinux testing a real pain.  If the patch posted at the top
>> of this thread isn't a suitable fix, we really should revert the
>> original patch.
>
> Since you want to test SELinux anyway, please test the attached one.

-- 
paul moore
www.paul-moore.com
