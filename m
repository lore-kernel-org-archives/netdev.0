From: John Stultz <john.stultz@linaro.org>
Subject: Re: [RFC v5 4/6] Remove duplicate code from ktime_get_raw_and_real code
Date: Wed, 6 Jan 2016 11:42:58 -0800
Message-ID: <CALAqxLVmQEXLGoq1k7S-Y97gLb_FSMbxzkZ6bFmnPH_sKt5X1A@mail.gmail.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
	<1451911523-8534-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451911523-8534-5-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 4, 2016 at 4:45 AM, Christopher S. Hall
<christopher.s.hall@intel.com> wrote:
> The code in ktime_get_snapshot() is a superset of the code in
> ktime_get_raw_and_real() code. Changes the latter to call the former. A
> side effect of this is that ktime_get_raw_and_real() returns two clock
> times corresponding to the *exact* same clock tick. Previously, this
> code read the underlying counter twice.
>
> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> ---
>  kernel/time/timekeeping.c | 20 ++++----------------
>  1 file changed, 4 insertions(+), 16 deletions(-)
>
> diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
> index 5a7f784..a0f096c 100644
> --- a/kernel/time/timekeeping.c
> +++ b/kernel/time/timekeeping.c
> @@ -910,26 +910,14 @@ EXPORT_SYMBOL_GPL(ktime_get_snapshot);
>   */
>  void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw, struct timespec64 *ts_real)
>  {
> -       struct timekeeper *tk = &tk_core.timekeeper;
> -       unsigned long seq;
> -       s64 nsecs_raw, nsecs_real;
> +       struct system_time_snapshot snap;
>
>         WARN_ON_ONCE(timekeeping_suspended);
>
> -       do {
> -               seq = read_seqcount_begin(&tk_core.seq);
> -
> -               *ts_raw = tk->raw_time;
> -               ts_real->tv_sec = tk->xtime_sec;
> -               ts_real->tv_nsec = 0;
> -
> -               nsecs_raw  = timekeeping_get_ns(&tk->tkr_raw);
> -               nsecs_real = timekeeping_get_ns(&tk->tkr_mono);
> -
> -       } while (read_seqcount_retry(&tk_core.seq, seq));
> +       ktime_get_snapshot(&snap);
>
> -       timespec64_add_ns(ts_raw, nsecs_raw);
> -       timespec64_add_ns(ts_real, nsecs_real);
> +       *ts_raw = ktime_to_timespec64(snap.raw);
> +       *ts_real = ktime_to_timespec64(snap.real);
>  }
>  EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);

Looks sane, but you might even be able to get rid of this function
entirely and modify the one user (pps_get_ts()) to use
ktime_get_snapshot().

thanks
-john
