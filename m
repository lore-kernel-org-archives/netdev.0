From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver
	asynchronous probe support
Date: Fri, 3 Oct 2014 09:54:51 -0700
Message-ID: <CAB=NE6WKZOnu2YwG5AN=+EsCVnqdHnYJdmVcLvHhMt4VZ5okrQ@mail.gmail.com>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
 <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com>
 <CAG-2HqWmVODJ6Q46t96mS9ALbeFjRcQ18ypwejY=ug0wCUVv-Q@mail.gmail.com>
 <20140930022751.GA14081@wotan.suse.de>
 <CAG-2HqUdFWBPUrHg2yezVVu7xedqTQDBxAW5nuYWKWJCTkZSBg@mail.gmail.com>
 <20140930152419.GF14081@wotan.suse.de>
 <CAG-2HqVBnXUKSRBrJE=gEKA3St5KMfdgAbx2vRfpF3qw_teLOg@mail.gmail.com>
 <20141002200612.GQ14081@wotan.suse.de>
 <CAG-2HqXxQG0fk2LsBT89fCZMmqo1NqX2xEK1aAT69hY8VLBoQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Petr Mladek <pmladek@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
 Michal Hocko <mhocko@suse.cz>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
 hare <hare@suse.com>,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>, werner@suse.com,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 "mpt-fusionlinux.pdl" <MPT-FusionLinux.pdl@avagotech.com>,
 Tim Gardner <tim.gardner@canonical.com>, Benjamin Poirier <bpoirier@suse.de>,
 Santosh Rastapur <santosh@chelsio.com>, Casey Leedom <leedom@chelsio.com>,
 Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>, dbueso@suse.com,
 Julia Lawall <julia.lawall@lip6.fr>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 Arjan van de Ven <arjan@linux.intel.com>,
 Abhijit Mahajan <a
To: Tom Gundersen <teg@jklm.no>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAG-2HqXxQG0fk2LsBT89fCZMmqo1NqX2xEK1aAT69hY8VLBoQQ@mail.gmail.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Fri, Oct 3, 2014 at 1:23 AM, Tom Gundersen <teg@jklm.no> wrote:
> On Thu, Oct 2, 2014 at 10:06 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
>> On Thu, Oct 02, 2014 at 08:12:37AM +0200, Tom Gundersen wrote:
>>> Making kmod a special case is of course possible. However, as long as
>>> there is no fundamental reason why kmod should get this special
>>> treatment, this just looks like a work-around to me.
>>
>> I've mentioned a series of five reasons why its a bad idea right now to
>> sigkill modules [0], we're reviewed them each and still at least
>> items 2-4 remain particularly valid fundamental reasons to avoid it
>
> So items 2-4 basically say "there currently are drivers that cannot
> deal with sigkill after a three minute timeout".

No, dealing with the sigkill gracefully is all related to 2) as it
says its probably a terrible idea to be triggering exit paths at
random points on device drivers on init / probe. And while one could
argue that perhaps that can be cleaned up I provided tons of
references and even *research effort* on this particular area so the
issues over this point should by no means easily be brushed off. And
it may be true that we can fix some things on Linux but a) that
requires a kernel upgrade on users and b) Some users may end up buying
hardware that only is supported through a proprietary driver and
getting those fixes is not trivial and almost impossible on some
cases.

3) says it is fundamentally incorrect to limit with any arbitrary
timeout the bus probe routine

4) talks about how the timeout is creating a limit on the number of
devices a device driver can support on Linux as follows give the
driver core batches *all* probes for one device driver serially:

   number_devices =          systemd_timeout
                      -------------------------------------
                         max known probe time for driver

We have device drivers which we *know* just on *probe* will take over
1 minute, this means that by default for these device drivers folks
can only install 3 devices of that type on a system. One can surely
address things on the kernel but again assuming folks use defaults and
don't upgrade their kernel the sigkill is simply limiting Linux right
now, even if it is for the short term.

> In the short-term we already have the solution: increase the timeout.

Short term implicates what will be supported for a while for tons of
deployments of systemd. The kernel command line work around for
increasing the timeout is a reactive measure, its not addressing the
problem architecturally. If the sigkill is going to be maintained for
kmod its implications should be well documented as well in terms of
the impact and limitations on both device drivers and number of
devices a driver can support.

> In the long-term, we have two choices, either permanently add some
> heuristic to udev to deal with drivers taking a very long time to be
> inserted, or fix the drivers not to take such a long time.

Drivers taking long on init should probably be addressed, drivers
taking long on probe are not broken specially since the driver core
probe's all supported devices on one device driver serially, so the
probe time is actually cumulative.

> A priori,
> it makes no sense to me that drivers spend unbounded amounts of time
> to get inserted, so fixing the drivers seems like the most reasonable
> approach to me. That said, I'm of course open to be proven wrong if
> there are some drivers that fundamentally _must_ take a long time to
> insert (but we should then discuss why that is and how we can best
> deal with the situation, rather than adding some hack up-front when we
> don't even know if it is needed).

Ok hold on. Async probe on the driver core will be a new feature and
there are even caveats that Tejun pointed out which are important for
distributions to consider before embracing it. Of course folks can
ignore these but by no means should it be considered that tons of
device device drivers were broken, what we are providing is a new
mechanism. And then there are device drivers which will need work in
order to use async probe, some will require fixes on init / probe
assumptions as I provided for the amd64_edac driver but for others
only time will tell what is required.

> Your patch series should go a long way towards fixing the drivers (and
> I imagine there being a lot of low-hanging fruit that can easily be
> fixed once your series has landed), and the fact that we have now
> increased the udev timeout from 30 to 180 seconds should also greatly
> reduce the problem.

Sure, I do ask for folks to revisit the short term solution though, I
did my best to communicate / document the issues.

  Luis
