From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 22 Sep 2014 09:36:31 -0700
Message-ID: <CAB=NE6WT0_be_WdNwX5WvcVShKnSKhYR0CJn67UJ9uSG9Rt0Ug@mail.gmail.com>
References: <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <20140909012227.GE11706@mtj.dyndns.org>
 <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
 <20140909012933.GF11706@mtj.dyndns.org> <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
 <20140909014754.GG11706@mtj.dyndns.org> <CAB=NE6VAe_96dezJmdXkOjy8mSz8EABX6i8C46GzUJRC-HLAZQ@mail.gmail.com>
 <20140909023943.GH11706@mtj.dyndns.org> <CAB=NE6XH64QLfwoE3r7uf3SYKNJMzP-tjUkrxDwVca7G2zOxBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasa
To: Tejun Heo <tj@kernel.org>, Santosh Rastapur <santosh@chelsio.com>,
	Jiri Kosina <jkosina@suse.cz>, Petr Mladek <pmladek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:62880 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbaIVQgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:36:54 -0400
In-Reply-To: <CAB=NE6XH64QLfwoE3r7uf3SYKNJMzP-tjUkrxDwVca7G2zOxBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2014 at 7:57 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
>> Why do we care about the priority of probing tasks?  Does that
>> actually make any meaningful difference?  If so, how?
>
> As I noted before -- I have yet to provide clear metrics but at least
> changing both init paths + probe from finit_module() to kthread
> certainly had a measurable time increase, I suspect using
> queue_work(system_unbound_wq, async_probe_work) will make probe
> slower. I'll get to these metrics this week.

The results are in and I'm glad to report my suspicions were incorrect
about kthread() being slower than queue_work(system_unbound_wq), it
actually works faster. Results will likely vary depending on
subsystems but in this particular case the cxgb4 driver was tested
requiring firmware loading and then without requiring firmware loading
and for these two types of driver loading all mechanisms make probe
take just about the same out of time. What was surprising was that
when firmware loading is required the amount of time it takes to run
probe does vary and quite considerably in terms of microseconds. The
discrepancies are by no means terrible... but should be considered if
one is thinking of large systems and if we do wish to optimize things
further and offer equivalent behavior, specially when probing multiple
devices with the same driver. The method used to collect the amount of
time for probe was to use:

ktime_t calltime, delta, rettime;
calltime = ktime_get();
driver_attach();
rettime = ktime_get();
delta = ktime_sub(rettime, calltime);
duration = (unsigned long long) ktime_to_ns(delta) >> 10;

And then print that time of microsecond out right after it finishes,
whether that be through the default kernel synchronous run or the
async runs.

The collection and testing was then done by Santosh. Details of the
collections are at:

https://bugzilla.novell.com/show_bug.cgi?id=877622

The summary:

The driver actually probed 2 cards in the tests so we don't have
results for 1 card, the kernel serially calls probe for each device so
to get the amount of time for one run lets just divide the results by
2. For each strategy there is the requirement of using firmware and a
run where no firmware loading is required. The results for both cards
are:

=====================================================================|
strategy                                fw (usec)       no-fw (usec) |
---------------------------------------------------------------------|
synchronous                             48945138        2615126      |
kthread                                 50132831        2619737      |
queue_work(system_unbound_wq)           49827323        2615262      |
---------------------------------------------------------------------|

For one device then that comes out to:

=====================================================================|
strategy                                fw (usec)       no-fw (usec) |
---------------------------------------------------------------------|
synchronous                             24472569        1307563      |
kthread                                 25066415.5      1309868.5    |
queue_work(system_unbound_wq)           24913661.5      1307631      |
---------------------------------------------------------------------|

Converting that to seconds:

=====================================================================|
strategy                                fw (s)          no-fw (s)    |
---------------------------------------------------------------------|
synchronous                             24.47           1.31         |
kthread                                 25.07           1.31         |
queue_work(system_unbound_wq)           24.91           1.31         |
---------------------------------------------------------------------|

Graph friendly versions of the results for probe of 1 device:

Probe with firmware:

http://drvbp1.linux-foundation.org/~mcgrof/images/probe-measurements/probe-cgxb4-firmware.png

Probe without firmware:

http://drvbp1.linux-foundation.org/~mcgrof/images/probe-measurements/probe-cgxb4-no-firmware.png

  Luis
