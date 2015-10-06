From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 06 Oct 2015 14:45:21 +0200
Message-ID: <5613C261.4080302@iogearbox.net>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com> <1444078101-29060-2-git-send-email-ast@plumgrid.com> <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56131B1F.80002-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/06/2015 02:51 AM, Alexei Starovoitov wrote:
> On 10/5/15 3:14 PM, Daniel Borkmann wrote:
>> One scenario that comes to mind ... what happens when there are kernel
>> pointers stored in skb->cb[] (either from the current layer or an old
>> one from a different layer that the skb went through previously, but
>> which did not get overwritten)?
>>
>> Socket filters could read a portion of skb->cb[] also when unprived and
>> leak that out through maps. I think the verifier doesn't catch that,
>> right?
...
> Please keep poking.

;)

I'm still wondering whether sysctl_bpf_enable_unprivileged is a good
way to go with regards to controlling capabilties of bpf(2), hmm, but
don't really have a good idea at the moment.

So, the rationale of this is to give it some soaking time before flipping
the switch that then defaults to on, and later on to still have a
possibility for an admin to turn it off (if not silently overwritten by
some system application later on ;)).

I think only having a Kconfig doesn't really make sense as distros
will blindly turn lots of stuff on anyway. A hidden Kconfig entry
that is not exposed into menuconfig might allow for sorting everything
out first, but with the issue of getting only little testing exposure.

If I see this correctly, perf_event_open(2) has a number of paranoia
levels with some helpers wrapped around it, f.e.:

/*
  * perf event paranoia level:
  *  -1 - not paranoid at all
  *   0 - disallow raw tracepoint access for unpriv
  *   1 - disallow cpu events for unpriv
  *   2 - disallow kernel profiling for unpriv
  */
int sysctl_perf_event_paranoid __read_mostly = 1;

Should instead something similar be adapted on bpf(2) as well? Or, would
that even be more painful for application developers shipping their stuff
through distros in the end (where they might then decide to just setup
everything BPF-related and then drop privs)?

I'm also wondering with regards to seccomp, which could adapt to eBPF at
some point and be used by unprivileged programs. Perhaps then, a single
paranoia alike setting might not suit to all eBPF subsystem users. Any
ideas?

Thanks,
Daniel
