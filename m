From: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Fri, 22 Aug 2014 12:39:00 -0700
Message-ID: <53F79C54.5050701@gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1408637945-10390-11-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/21/2014 09:19 AM, Jiri Pirko wrote:
> Benefit from the possibility to work with flows in switch devices and
> use the swdev api to offload flow datapath.

we should add a description here on the strategy being used.

If I read this correctly this will try to add any flow to the
hardware along with the actions and duplicate it in software.

There are a couple things I don't like,

  - this requires OVS to be loaded to work. If all I want is
    direct access to the hardware flow tables requiring openvswitch.ko
    shouldn't be needed IMO. For example I may want to use the
    hardware flow tables with something not openvswitch and we
    shouldn't preclude that.

  - Also there is no programmatic way to learn which flows are
    in hardware and which in software. There is a pr_warn but
    that doesn't help when interacting with the hardware remotely.
    I need some mechanism to dump the set of hardware tables and
    the set of software tables.

  - Simply duplicating the software flow/action into
    hardware may not optimally use the hardware tables. If I have
    a TCAM in hardware for instance. (This is how I read the patch
    let me know if I missed something)

  - I need a way to specify put this flow/action in hardware,
    put this flow/action in software, or put this in both software
    and hardware.

    We did this with a bitmask in the fdb L2 stuff and it seems to
    work reasonable well so maybe something like that would help.

    For example if I don't have this what happens if I have an
    entry to decrement TTL in both hardware and software. If the
    flow hits both the hardware path and software path the TTL
    gets decremented. Here userspace needs to indicate where to
    do the decrement to avoid the duplication.

I think if we can pull this out OVS and add the hw/sw bitmask (or
maybe a better implementation of that idea) then this should work
for the stuff I'm looking at. I want to try and get it working on
the i40e driver as a fdir replacement but it might take me a bit
to get to it.


Thanks,
John


-- 
John Fastabend         Intel Corporation
