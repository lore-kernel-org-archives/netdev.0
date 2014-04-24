From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC v3 10/10] openvswitch: add
 support for datapath hardware offload
Date: Thu, 24 Apr 2014 17:46:14 +0200
Message-ID: <20140424154614.GB2864@minipsycho.orion>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
 <1397736938-11838-1-git-send-email-jiri@resnulli.us>
 <5359259B.3020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5359259B.3020402-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Thu, Apr 24, 2014 at 04:54:19PM CEST, john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>On 04/17/2014 05:15 AM, Jiri Pirko wrote:
>>Benefit from the possibility to work with flows in switch devices and
>>use the swdev api to offload flow datapath.
>>
>>Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>>---
>
>
>[...]
>
>>
>>@@ -840,13 +841,15 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
>>  		flow->flow.key = masked_key;
>>  		flow->flow.unmasked_key = key;
>>  		rcu_assign_pointer(flow->sf_acts, acts);
>>+		acts = NULL;
>>
>>  		/* Put flow in bucket. */
>>  		error = ovs_flow_tbl_insert(&dp->table, flow, &mask);
>>-		if (error) {
>>-			acts = NULL;
>>+		if (error)
>>  			goto err_flow_free;
>>-		}
>>+		error = ovs_hw_flow_insert(dp, flow, flow->sf_acts);
>>+		if (error)
>>+			goto err_flow_tbl_remove;
>>
>>  		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
>>  	} else {
>
>Hi Jiri,
>
>If I read this correctly it looks like you do a insert into software
>flow tables and then an insert into the hardware flow tables. Into
>all lowerdevs. Let me know if I got this wrong.

It should be sufficient to use one-port-per-switch to insert this. I
just insert it to all and if 2 ports of the same switch are used the
switch should see that the flow is already there and bail out. This is
rough so far. Needs some polishing.
		

>
>This might break on some rules (an insert tag for example) and also
>underutilize the switch resources by pushing rules into the switch that
>we really only need in software tables or maybe only on some set of
>ports.

I thought that I would introduce a flag that would say "push this flow
to hw".

>
>I think we need to allow applications direct access to the flow table
>via netlink so I can write my policy in user space and not require
>OVS. If OVS wants to support a mode where it does this automagically
>it can support it in userspace and the kernel side does not need to
>change.

The idea was to use the existing ovs api for this so it would be smooth
to userspace. For non-ovs usage there is certainly possible to introduce
new iface which would just call same ndos.

>
>Thanks,
>John
>
>
>-- 
>John Fastabend         Intel Corporation
