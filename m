From: Daniel Borkmann via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH net 2/2] bpf/verifier: fix min/max
	handling in BPF_SUB
Date: Fri, 21 Jul 2017 16:30:17 +0200
Message-ID: <59720FF9.10901@iogearbox.net>
References: <2ebcb201-2f18-7276-f4f9-f2bbaffae179@solarflare.com>
	<e3fa964f-54f2-7310-59d1-41a4b7ad9a5b@solarflare.com>
Reply-To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josef-DigfWCa+lFGyeJad7bwFQA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <e3fa964f-54f2-7310-59d1-41a4b7ad9a5b-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 07/21/2017 03:37 PM, Edward Cree wrote:
> We have to subtract the src max from the dst min, and vice-versa, since
>   (e.g.) the smallest result comes from the largest subtrahend.
>
> Fixes: 484611357c19 ("bpf: allow access into map value arrays")
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>

LGTM, thanks for the fix!

Acked-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>

> ---
>   kernel/bpf/verifier.c | 21 +++++++++++++++------
>   1 file changed, 15 insertions(+), 6 deletions(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index af9e84a..664d939 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1865,10 +1865,12 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
>   	 * do our normal operations to the register, we need to set the values
>   	 * to the min/max since they are undefined.
>   	 */
> -	if (min_val == BPF_REGISTER_MIN_RANGE)
> -		dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
> -	if (max_val == BPF_REGISTER_MAX_RANGE)
> -		dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
> +	if (opcode != BPF_SUB) {
> +		if (min_val == BPF_REGISTER_MIN_RANGE)
> +			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
> +		if (max_val == BPF_REGISTER_MAX_RANGE)
> +			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
> +	}
>
>   	switch (opcode) {
>   	case BPF_ADD:
> @@ -1879,10 +1881,17 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
>   		dst_reg->min_align = min(src_align, dst_align);
>   		break;
>   	case BPF_SUB:
> +		/* If one of our values was at the end of our ranges, then the
> +		 * _opposite_ value in the dst_reg goes to the end of our range.
> +		 */
> +		if (min_val == BPF_REGISTER_MIN_RANGE)
> +			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
> +		if (max_val == BPF_REGISTER_MAX_RANGE)
> +			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
>   		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
> -			dst_reg->min_value -= min_val;
> +			dst_reg->min_value -= max_val;
>   		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
> -			dst_reg->max_value -= max_val;
> +			dst_reg->max_value -= min_val;
>   		dst_reg->min_align = min(src_align, dst_align);
>   		break;
>   	case BPF_MUL:
>
