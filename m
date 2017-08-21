From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next] bpf/verifier: track liveness
	for pruning
Date: Mon, 21 Aug 2017 19:36:44 +0100
Message-ID: <b39b4a6f-907e-c684-b9e4-285ff9c7ca9a@solarflare.com>
References: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
	<89ff34f7-84ee-0e0a-3766-5b4d046189bf@fb.com>
	<b8a46388-74ea-81f9-df08-3b6b88042229@solarflare.com>
	<5d4e12aa-6861-a176-a8cf-a766bbca0a7a@fb.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov
	<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5d4e12aa-6861-a176-a8cf-a766bbca0a7a-b10kYP2dOMg@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 19/08/17 00:37, Alexei Starovoitov wrote:
> that '14: safe' above is not correct.
>
> Disabling liveness as:
> @@ -3282,7 +3288,7 @@ static bool regsafe(struct bpf_reg_state *rold,
>                     struct bpf_reg_state *rcur,
>                     bool varlen_map_access, struct idpair *idmap)
>  {
> -       if (!(rold->live & REG_LIVE_READ))
> +       if (0 && !(rold->live & REG_LIVE_READ))
>
> makes the test work properly and proper verifier output is:
> from 9 to 11: R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) R1=inv(id=0,smax_value=10) R2=inv11 R10=fp0
> 11: (64) (u32) r1 <<= (u32) 2
> 12: (0f) r0 += r1
> 13: (05) goto pc+0
> 14: (7a) *(u64 *)(r0 +0) = 4
>
> R0=map_value(id=0,off=0,ks=8,vs=48,umax_value=17179869180,var_off=(0x0; 0x3fffffffc)) R1=inv(id=0,umax_value=17179869180,var_off=(0x0; 0x3fffffffc)) R2=inv11 R10=fp0
> R0 unbounded memory access, make sure to bounds check any array access into a map
>
> I don't yet understand the underlying reason. R0 should have been
> marked as LIVE_READ by ST_MEM...
> Please help debug it further.
>
Having added a bunch of debugging, I found out that indeed R0 _had_ been
 marked as LIVE_READ.  The problem was that env->varlen_map_value_access
 wasn't set, because the access was at a constant offset (imm=0), but then
 when we compare register states we just say "oh yeah, it's a map_value,
 we don't need to look at the var_off".
This probably results from my unifying PTR_TO_MAP_VALUE with
 PTR_TO_MAP_VALUE_ADJ; before that the old and new R0 would have different
 reg->type so wouldn't match.
I'm tempted to just rip out env->varlen_map_value_access and always check
 the whole thing, because honestly I don't know what it was meant to do
 originally or how it can ever do any useful pruning.  While drastic, it
 does cause your test case to pass.

I'm not quite sure why your test passed when you disabled liveness, though;
 that I can't explain.

-Ed
