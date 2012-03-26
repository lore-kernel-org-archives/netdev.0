From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Mon, 26 Mar 2012 15:32:08 -0400
Message-ID: <CAAsGZS4Jqe5ZcZyGZjurmjBCgzj=+a0cgHAEwB+esXNoQ3P7NQ@mail.gmail.com>
References: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321170003.GA5533@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
	<20120322064107.GB2182@netboy.at.omicron.at>
	<CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
	<CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
	<20120326152730.GA10212@localhost.localdomain>
	<CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Mar 26, 2012 at 2:56 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:

> I am curious how you see a kernel thread resolving the Tx/Rx issue? or is the
> kernel thread being used by gettime? I don't believe we can wait for the Tx/Rx

tx, rx path and kernel thread will use seq_lock_isave(tmreg_lock).

A new 'u64 cached_ns' will be introduced.

tx and rx path can update 'cached_ns' when they read the NIC counter.

A kernel-thread should be scheduled periodically, will read the NIC
counter and update cached_ns. It will use a _trylock variant. If the
lock fails then its a hint that 'cached_ns' is getting updated
somewhere, so just refresh the timer. Periodic update is needed to
handle idle/bursty link conditions because the Rx/tx path may not run
that often.

gettime uses read_seq_lock and reads 'cached_ns'. I mean we could also
do a atomic_read(?).


> path, because if we take too long the software sees it as a dropped timestamp.

What code-path is this?


> How would we only allow one app? Any app with permissions could call the ioctls.
> I do agree that having too many ioctls is a problem. Even in cases where PTP is

We don't. So this is what I'm thinking. Ideally speaking only 1 app
should be adjusting the host-clock and 1 app per NIC if you adjust
NIC's clock. Ignore the host-clock app. Once you enforce the
rate-limit, driver will return -EBUSY if you exceed it. Too many
EBUSYs will provide a hint on user-side.


Chetan

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
