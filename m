From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 11:56:24 +0100
Message-ID: <87612skwfb.fsf@doppelsaurus.mobileactivedefense.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
	<CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz\@infradead.org" <peterz@infradead.org>,
	"davem\@davemloft.net" <davem@davemloft.net>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:53359 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755360AbbI3K5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 06:57:53 -0400
In-Reply-To: <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
	(Mathias Krause's message of "Wed, 30 Sep 2015 07:54:29 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathias Krause <minipli@googlemail.com> writes:
> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>> drop the reference on the original socket 'o'. Thus, we can now close socket
>> 'o' without unregistering from epoll. Then, when we either close the ep
>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>> race per se, but can be triggered sequentially.
>
> Sounds profound, but the reproducers calls connect only once per
> socket. So there is no "connect to a new socket", no?
> But w/e, see below.

In case you want some information on this: This is a kernel warning I
could trigger (more than once) on the single day I could so far spend
looking into this (3.2.54 kernel):

Sep 15 19:37:19 doppelsaurus kernel: WARNING: at lib/list_debug.c:53 list_del+0x9/0x30()
Sep 15 19:37:19 doppelsaurus kernel: Hardware name: 500-330nam
Sep 15 19:37:19 doppelsaurus kernel: list_del corruption. prev->next should be ffff88022c38f078, but was dead000000100100
Sep 15 19:37:19 doppelsaurus kernel: Modules linked in: snd_hrtimer binfmt_misc af_packet nf_conntrack loop snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm sg snd_page_alloc snd_seq_du
mmy sr_mod snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_timer ath9k snd cdrom ath9k_common ath9k_hw r8169 mii ath usb_storage unix
Sep 15 19:37:19 doppelsaurus kernel: Pid: 3340, comm: a.out Tainted: G        W    3.2.54-saurus-vesa #9
Sep 15 19:37:19 doppelsaurus kernel: Call Trace:
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff811c1e00>] ? __list_del_entry+0x80/0xc0
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff81036ad9>] ? warn_slowpath_common+0x79/0xc0
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff81036bd5>] ? warn_slowpath_fmt+0x45/0x50
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff811c1e49>] ? list_del+0x9/0x30
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff81051509>] ? remove_wait_queue+0x29/0x50
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff810fde62>] ? ep_unregister_pollwait.isra.9+0x32/0x50
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff810fdeaa>] ? ep_remove+0x2a/0xc0
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff810fe9ae>] ? eventpoll_release_file+0x5e/0x90
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff810c76f6>] ? fput+0x1c6/0x220
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff810c3b7f>] ? filp_close+0x5f/0x90
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff810c3c36>] ? sys_close+0x86/0xd0
Sep 15 19:37:19 doppelsaurus kernel: [<ffffffff8141f43b>] ? system_call_fastpath+0x16/0x1b

The dead000000100100 is one of the list poison values a linkage pointer
is set to during/ after removal from a list. The particular warning
means that entry->prev (the item being removed) pointed to another entry
whose next pointer was not the address of entry but
dead000000100100. Most likely, this means there's a list insert racing
with a list remove somewhere here where the insert picks up the pointer
to the previous item while it is still on the list and uses it while the
delete removes it, with delete having the last word and thus setting
prev->next to dead000000100100 after the insert set it to the address of
the item to be inserted.
