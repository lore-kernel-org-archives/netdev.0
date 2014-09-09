From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 8 Sep 2014 19:57:28 -0700
Message-ID: <CAB=NE6XH64QLfwoE3r7uf3SYKNJMzP-tjUkrxDwVca7G2zOxBQ@mail.gmail.com>
References: <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <20140909012227.GE11706@mtj.dyndns.org>
 <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
 <20140909012933.GF11706@mtj.dyndns.org> <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
 <20140909014754.GG11706@mtj.dyndns.org> <CAB=NE6VAe_96dezJmdXkOjy8mSz8EABX6i8C46GzUJRC-HLAZQ@mail.gmail.com>
 <20140909023943.GH11706@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Redd
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140909023943.GH11706@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 8, 2014 at 7:39 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Mon, Sep 08, 2014 at 07:28:58PM -0700, Luis R. Rodriguez wrote:
>> > Given that the behvaior change is from driver core and that device
>> > probing can happen post-loading anyway,
>>
>> Ah but lets not forget Dmitry's requirement which is for in-kernel
>> drivers. We'd need to deal with both built-in and modules. Dmitry's
>> case is completely orthogonal to the systemd issue and is just needed
>> to help not stall boot but I see no reason to blend these two issues
>> into one requirement together.
>
> Maybe we can piggy back the two on the same mechanism but as you said
> the two issues are orthogonal.  Let's keep it that way for now.  We
> need them separate anyway for backports.

OK.

>> In terms of approach we would still need to decide on a path for how
>> to do asynch probing for both in-kernel drivers and modules, do we
>> want async_schedule(), or queue_work()? If async_schedule() do we want
>> to use a new domain or a new one shared for all drivers? Priority on
>
> I don't think async_schedule() is the right mechanism for this use
> case as the mechanism is inherently opportunistic.  It also gets
> tangled up with async synchronization at the end of module loading.
>
>> the schedular was one of my other concerns which we'd need to make
>> right to match existing load on drivers through finit_module() and
>> synchronous probe.
>
> Why do we care about the priority of probing tasks?  Does that
> actually make any meaningful difference?  If so, how?

As I noted before -- I have yet to provide clear metrics but at least
changing both init paths + probe from finit_module() to kthread
certainly had a measurable time increase, I suspect using
queue_work(system_unbound_wq, async_probe_work) will make probe
slower. I'll get to these metrics this week.

>> > Userland could backport a fix to set the sysctl.  Given that we need
>> > both synchrnous and asynchronous behaviors, it's unlikely that we can
>> > come up with a solution which doesn't need cooperation from userland.
>>
>> True and then the timeout would also have to be skipped for device
>> drivers that have the sync_probe flag set, so I guess we'd need to
>
> I'm not sure about skipping for sync_probe flag.  That seems like an
> implementation detail to me.  Sure, we do that now because we don't
> have a better way of figuring out whether request_module() is waiting
> for it or not but hopefully we'd be able to in the future.

Oh I was not thinking about just request_modules() users but also any
of those stragglers which we might have ended up finding through run
time analysis. The alternative right now is these drivers won't load.
No bueno.

> I think we
> just should make exceptions sensible so that it works fine in practice
> for now (and I don't think that'd be too hard).  So, the only
> cooperation necessary from userland would be just saying "I don't
> wanna wait for device probing on module load."

But we're talking about drivers that have a flag that says 'you gotta
wait sucker', what do we want systemd to do then? I'd be happy if it'd
would not send the sigkill for these drivers, for example.

  Luis
