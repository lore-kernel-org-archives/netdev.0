From: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
	for datapath hardware offload
Date: Fri, 22 Aug 2014 15:53:34 -0700
Message-ID: <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <53F79C54.5050701-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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


On Aug 22, 2014, at 12:39 PM, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:

> On 08/21/2014 09:19 AM, Jiri Pirko wrote:
>> Benefit from the possibility to work with flows in switch devices and
>> use the swdev api to offload flow datapath.
> =

> we should add a description here on the strategy being used.
> =

> If I read this correctly this will try to add any flow to the
> hardware along with the actions and duplicate it in software.
> =

> There are a couple things I don't like,
> =

> - this requires OVS to be loaded to work. If all I want is
>   direct access to the hardware flow tables requiring openvswitch.ko
>   shouldn't be needed IMO. For example I may want to use the
>   hardware flow tables with something not openvswitch and we
>   shouldn't preclude that.
> =


The intent is to use openvswitch.ko=92s struct sw_flow to program hardware =
via the ndo_swdev_flow_* ops, but otherwise be independent of OVS.  So the =
upper layer of the driver is struct sw_flow and any module above the driver=
 can construct a struct sw_flow and push it down via ndo_swdev_flow_*.  So =
your non-OVS use-case should be handled.  OVS is another use-case.  struct =
sw_flow should not be OVS-aware, but rather a generic flow match/action suf=
ficient to offload the data plane to HW.

> - Also there is no programmatic way to learn which flows are
>   in hardware and which in software. There is a pr_warn but
>   that doesn't help when interacting with the hardware remotely.
>   I need some mechanism to dump the set of hardware tables and
>   the set of software tables.

Agreed, we need a way to annotate which flows are installed hardware.

> - Simply duplicating the software flow/action into
>   hardware may not optimally use the hardware tables. If I have
>   a TCAM in hardware for instance. (This is how I read the patch
>   let me know if I missed something)

The hardware-specific driver is the right place to handle optimizing the fl=
ow/action in hardware since only the driver can know the size/shape of the =
device.  struct sw_flow is a generic flow description; how (or if) a flow g=
ets programmed into hardware must be handled in the swdev driver.  If the d=
evice driver can=92t make the sw_flow fit into HW because of resource limit=
ations or the flow simply can=92t be represented in HW, then the flow is SW=
 only.  =


In the rocker driver posted in this patch set, the steps are to parse the s=
truct sw_flow to figure out what type of flow match/action we=92re dealing =
with (L2 or L3 or L4, ucast or mcast, ipv4 or ipv6, etc) and then install t=
he correct entries into the corresponding device tables within the constrai=
nts of the device=92s pipeline.  Any optimizations, like coalescing HW entr=
ies, is something only the driver can do.

> =

> - I need a way to specify put this flow/action in hardware,
>   put this flow/action in software, or put this in both software
>   and hardware.
> =


This seems above the swdev layer.  In other words, don=92t call ndo_swdev_f=
low_* if you don=92t want flow match/action install in HW.

>   We did this with a bitmask in the fdb L2 stuff and it seems to
>   work reasonable well so maybe something like that would help.
> =

>   For example if I don't have this what happens if I have an
>   entry to decrement TTL in both hardware and software. If the
>   flow hits both the hardware path and software path the TTL
>   gets decremented. Here userspace needs to indicate where to
>   do the decrement to avoid the duplication.

I=92m not following why a flow would hit both HW and SW paths.  That seems =
bad, and negating to effort of offloading the flow to HW in the first place=
.  My simple view is if flow hits HW path, then SW path is unaware.  Clearl=
y work is needed to provide coherent view to user with respect to stat coun=
ters and such, but I believe do-able.

> =

> I think if we can pull this out OVS and add the hw/sw bitmask (or
> maybe a better implementation of that idea) then this should work
> for the stuff I'm looking at. I want to try and get it working on
> the i40e driver as a fdir replacement but it might take me a bit
> to get to it.

That sounds cool and would really help get the interface in place.  Take an=
other look at the way Jiri has busted out sw_flow.h and see if this works f=
or you outside of an OVS context.  If not, we need to fix it.


> =

> Thanks,
> John
> =

> =

> -- =

> John Fastabend         Intel Corporation
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-scott
