From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Thu, 01 Oct 2015 13:10:44 +0100
Message-ID: <87bnciiybf.fsf@doppelsaurus.mobileactivedefense.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
	<CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
	<560C9CFE.6090509@akamai.com>
	<87oagiho88.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
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
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87oagiho88.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Thu, 01 Oct 2015 11:33:59 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Jason Baron <jbaron@akamai.com> writes:
>> On 09/30/2015 01:54 AM, Mathias Krause wrote:
>>> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>>>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>>>> drop the reference on the original socket 'o'. Thus, we can now close socket
>>>> 'o' without unregistering from epoll. Then, when we either close the ep
>>>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>>>> race per se, but can be triggered sequentially.
>>> 
>>> Sounds profound, but the reproducers calls connect only once per
>>> socket. So there is no "connect to a new socket", no?
>>> But w/e, see below.
>>
>> Yes, but it can be reproduced this way too. It can also happen with a
>> close() on the remote peer 'o', and a send to 'o' from 's', which the
>> reproducer can do as pointed out Michal. The patch I sent deals with
>> both cases.
>
> As Michal also pointed out, there's a unix_dgram_disconnected routine
> being called in both cases and insofar "deregistering" anything beyond
> what unix_dgram_disconnected (and - insofar I can tell this -
> unix_release_sock) already do is actually required, this would be the
> obvious place to add it. A good step on the way to that would be to
> write (and post) some test code which actually reproduces the problem in
> a predictable way.

Test program (assumes that it can execute itself as ./a.out):

-------------
#include <fcntl.h>
#include <pthread.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/epoll.h>
#include <signal.h>
#include <unistd.h>

static int sk;

static void *epoller(void *unused)
{
    struct epoll_event epev;
    int epfd;
    
    epfd = epoll_create(1);

    epev.events = EPOLLOUT;
    epoll_ctl(epfd, EPOLL_CTL_ADD, sk, &epev);
    epoll_wait(epfd, &epev, 1, 5000);

    execl("./a.out", "./a.out", (void *)0);

    return NULL;
}

int main(void)
{
    struct sockaddr_un sun;
    pthread_t tid;
    int tg0, tg1, rc;

    sun.sun_family = AF_UNIX;
    
    tg0 = socket(AF_UNIX, SOCK_DGRAM, 0);
    strncpy(sun.sun_path, "/tmp/tg0", sizeof(sun.sun_path));
    unlink(sun.sun_path);
    bind(tg0, (struct sockaddr *)&sun, sizeof(sun));
    
    tg1 = socket(AF_UNIX, SOCK_DGRAM, 0);
    strncpy(sun.sun_path, "/tmp/tg1", sizeof(sun.sun_path));
    unlink(sun.sun_path);
    bind(tg1, (struct sockaddr *)&sun, sizeof(sun));

    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    connect(sk, (struct sockaddr *)&sun, sizeof(sun));

    fcntl(sk, F_SETFL, fcntl(sk, F_GETFL) | O_NONBLOCK);
    
    while ((rc = write(sk, "bla", 3)) != -1);

    pthread_create(&tid, NULL, epoller, NULL);

    usleep(5);

    strncpy(sun.sun_path, "/tmp/tg0", sizeof(sun.sun_path));
    connect(sk, (struct sockaddr *)&sun, sizeof(sun));
    close(tg1);
    
    pause();

    return 0;
}
-----------------

Inserting a

struct list_head *p;

p = &u->peer_wait.task_list;
WARN_ON(p->next != p || p->prev != p);

into unix_sock_destructor triggers a warning and after running for a
while, one also gets the list corruption warnings, example

Oct  1 12:53:38 doppelsaurus kernel: WARNING: at lib/list_debug.c:54 list_del+0x9/0x30()
Oct  1 12:53:38 doppelsaurus kernel: Hardware name: 500-330nam
Oct  1 12:53:38 doppelsaurus kernel: list_del corruption. prev->next should be ffff880232634420, but was ffff880224f878c8
Oct  1 12:53:38 doppelsaurus kernel: Modules linked in: snd_hrtimer binfmt_misc af_packet nf_conntrack loop snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm ath9k ath9k_common ath9k_hw snd_seq_dummy snd_page_alloc snd_seq_oss snd_seq_midi_event snd_seq sg ath sr_mod snd_seq_device cdrom snd_timer snd r8169 mii usb_storage unix
Oct  1 12:53:38 doppelsaurus kernel: Pid: 4619, comm: a.out Tainted: G        W    3.2.54-saurus-vesa #18
Oct  1 12:53:38 doppelsaurus kernel: Call Trace:
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff811c1e00>] ? __list_del_entry+0x80/0x100
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff81036ad9>] ? warn_slowpath_common+0x79/0xc0
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff81036bd5>] ? warn_slowpath_fmt+0x45/0x50
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff811c1e89>] ? list_del+0x9/0x30
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff81051509>] ? remove_wait_queue+0x29/0x50
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff810fde62>] ? ep_unregister_pollwait.isra.9+0x32/0x50
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff810fdeaa>] ? ep_remove+0x2a/0xc0
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff810fe9ae>] ? eventpoll_release_file+0x5e/0x90
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff810c76f6>] ? fput+0x1c6/0x220
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff810c3b7f>] ? filp_close+0x5f/0x90
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff81039e35>] ? put_files_struct+0xb5/0x110
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff8103a4ef>] ? do_exit+0x59f/0x750
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff8103a9b8>] ? do_group_exit+0x38/0xa0
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff8103aa32>] ? sys_exit_group+0x12/0x20
Oct  1 12:53:38 doppelsaurus kernel: [<ffffffff8141f5fe>] ? tracesys+0xd0/0xd5
Oct  1 12:53:38 doppelsaurus kernel: ---[ end trace ba5c51cbfeb664d8 ]---

Doing "the signalfd_cleanup" thing should prevent this (didn't test this
so far). I still think the correct solution would be to clean this up in
unix_dgram_disconnected.
