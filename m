From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v3 4/4] posix-timers: make it configurable
Date: Tue, 8 Nov 2016 10:48:06 -0800
Message-ID: <CALAqxLVL-YLBYynW1c+vUV8y=HFQc7o5QbO47kKog0J-xpgSWw@mail.gmail.com>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
 <1478556899-2951-5-git-send-email-nicolas.pitre@linaro.org>
 <CALAqxLVrGRW3ODzZk=4-8FSLe5wBwHJSOEAW=+kMFjTRoe1HzQ@mail.gmail.com> <alpine.LFD.2.20.1611081311420.11818@knanqh.ubzr>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1611081311420.11818@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 8, 2016 at 10:19 AM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> On Tue, 8 Nov 2016, John Stultz wrote:
>
>> One spot of concern is that the
>> tools/testing/selftests/timers/posix_timers.c test hangs testing
>> virtual itimers. Looking through the code I'm not seeing where an
>> error case is missed.
>>
>> The strace looks like:
>> ...
>> write(1, "Testing posix timers. False nega"..., 66Testing posix
>> timers. False negative may happen on CPU execution
>> ) = 66
>> write(1, "based timers if other threads ru"..., 48based timers if
>> other threads run on the CPU...
>> ) = 48
>> write(1, "Check itimer virtual... ", 24Check itimer virtual... ) = 24
>> rt_sigaction(SIGVTALRM, {0x400a80, [VTALRM], SA_RESTORER|SA_RESTART,
>> 0x7fb73306ccb0}, {SIG_DFL, [], 0}, 8) = 0
>> gettimeofday({1478710402, 937476}, NULL) = 0
>> setitimer(ITIMER_VIRTUAL, {it_interval={0, 0}, it_value={2, 0}}, NULL) = 0
>> <Hang>
>>
>>
>> Where as with posix timers enabled:
>> ...
>> write(1, "Testing posix timers. False nega"..., 138Testing posix
>> timers. False negative may happen on CPU execution
>> based timers if other threads run on the CPU...
>> Check itimer virtual... ) = 138
>> rt_sigaction(SIGVTALRM, {0x400a80, [VTALRM], SA_RESTORER|SA_RESTART,
>> 0x7f231ba8ccb0}, {SIG_DFL, [], 0}, 8) = 0
>> gettimeofday({1478626751, 904856}, NULL) = 0
>> setitimer(ITIMER_VIRTUAL, {it_interval={0, 0}, it_value={2, 0}}, NULL) = 0
>> --- SIGVTALRM {si_signo=SIGVTALRM, si_code=SI_KERNEL} ---
>> rt_sigreturn()                          = 0
>
> I'll have a look.
>
>> So I suspect you were a little too aggressive with the #ifdefs around
>> the itimers/signal code, or we need to make sure we return an error on
>> the setitimer ITIMER_VIRTUAL case as well.
>
> Well, it seemed to me that with POSIX_TIMERS=n, all the code that would
> set up that signal is gone, so there was no point keeping the code to
> deliver it.
>
> Now... would it make more sense to remove itimer support as well when
> POSIX_TIMERS=n?  The same reasoning would apply.

Yes, returning an error with itimers seems needed if the signal bits
are missing.

Though I do worry that since getitimer/setitimer are older obsolete
interfaces which the posix timers api is supposed to replace, folks
might be surprised to see it removed when setting POSIX_TIMERS=n. So
some additional notes in the kconfig description may be needed.

thanks
-john
