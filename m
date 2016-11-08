From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v3 4/4] posix-timers: make it configurable
Date: Tue, 8 Nov 2016 09:42:54 -0800
Message-ID: <CALAqxLVrGRW3ODzZk=4-8FSLe5wBwHJSOEAW=+kMFjTRoe1HzQ@mail.gmail.com>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org> <1478556899-2951-5-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Marek <mmarek@suse.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1478556899-2951-5-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 7, 2016 at 2:14 PM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> Some embedded systems have no use for them.  This removes about
> 22KB from the kernel binary size when configured out.
>
> Corresponding syscalls are routed to a stub logging the attempt to
> use those syscalls which should be enough of a clue if they were
> disabled without proper consideration. They are: timer_create,
> timer_gettime: timer_getoverrun, timer_settime, timer_delete,
> clock_adjtime.
>
> The clock_settime, clock_gettime, clock_getres and clock_nanosleep
> syscalls are replaced by simple wrappers compatible with CLOCK_REALTIME,
> CLOCK_MONOTONIC and CLOCK_BOOTTIME only which should cover the vast
> majority of use cases with very little code.
>
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>
> Acked-by: Richard Cochran <richardcochran@gmail.com>

So I have no design objections to the patch overall.

I ran this through my timekeeping tests last night and it passed a
fair number of the tests, considering.

I of course see a lot of failures around timer_creates failing
(set-timer-lat), and cases where clockids aren't supported.
So I'll need to see about updating the tests to fail more gracefully
with this change.

One spot of concern is that the
tools/testing/selftests/timers/posix_timers.c test hangs testing
virtual itimers. Looking through the code I'm not seeing where an
error case is missed.

The strace looks like:
...
write(1, "Testing posix timers. False nega"..., 66Testing posix
timers. False negative may happen on CPU execution
) = 66
write(1, "based timers if other threads ru"..., 48based timers if
other threads run on the CPU...
) = 48
write(1, "Check itimer virtual... ", 24Check itimer virtual... ) = 24
rt_sigaction(SIGVTALRM, {0x400a80, [VTALRM], SA_RESTORER|SA_RESTART,
0x7fb73306ccb0}, {SIG_DFL, [], 0}, 8) = 0
gettimeofday({1478710402, 937476}, NULL) = 0
setitimer(ITIMER_VIRTUAL, {it_interval={0, 0}, it_value={2, 0}}, NULL) = 0
<Hang>


Where as with posix timers enabled:
...
write(1, "Testing posix timers. False nega"..., 138Testing posix
timers. False negative may happen on CPU execution
based timers if other threads run on the CPU...
Check itimer virtual... ) = 138
rt_sigaction(SIGVTALRM, {0x400a80, [VTALRM], SA_RESTORER|SA_RESTART,
0x7f231ba8ccb0}, {SIG_DFL, [], 0}, 8) = 0
gettimeofday({1478626751, 904856}, NULL) = 0
setitimer(ITIMER_VIRTUAL, {it_interval={0, 0}, it_value={2, 0}}, NULL) = 0
--- SIGVTALRM {si_signo=SIGVTALRM, si_code=SI_KERNEL} ---
rt_sigreturn()                          = 0
gettimeofday({1478626753, 906137}, NULL) = 0
write(1, "[OK]\nCheck itimer prof... ", 26[OK]
...

So I suspect you were a little too aggressive with the #ifdefs around
the itimers/signal code, or we need to make sure we return an error on
the setitimer ITIMER_VIRTUAL case as well.

thanks
-john
