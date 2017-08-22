From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] bpf/verifier: when pruning a
 branch, ignore its write marks
Date: Tue, 22 Aug 2017 08:24:17 -0700
Message-ID: <0ba423e6-8629-37b1-b772-0734f1fb5489@fb.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
	<d1a5b78a-8f5c-50d9-08a2-eb7c4829a478@solarflare.com>
Reply-To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei
	Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann
	<daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <d1a5b78a-8f5c-50d9-08a2-eb7c4829a478-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 8/22/17 6:27 AM, Edward Cree wrote:
> The fact that writes occurred in reaching the continuation state does
>  not screen off its reads from us, because we're not really its parent.
> So detect 'not really the parent' in do_propagate_liveness, and ignore
>  write marks in that case.
>
> Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> ---
>  kernel/bpf/verifier.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 1e3f56c..711bdbd 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -3420,6 +3420,7 @@ static bool states_equal(struct bpf_verifier_env *env,
>  static bool do_propagate_liveness(const struct bpf_verifier_state *state,
>  				  struct bpf_verifier_state *parent)
>  {
> +	bool writes = parent == state->parent; /* Observe write marks */
>  	bool touched = false; /* any changes made? */
>  	int i;
>
> @@ -3431,7 +3432,9 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
>  	for (i = 0; i < BPF_REG_FP; i++) {
>  		if (parent->regs[i].live & REG_LIVE_READ)
>  			continue;
> -		if (state->regs[i].live == REG_LIVE_READ) {
> +		if (writes && (state->regs[i].live & REG_LIVE_WRITTEN))
> +			continue;
> +		if (state->regs[i].live & REG_LIVE_READ) {

makes sense to me.
if i understand correctly it not only should make the liveness marking
correct, but improve the numbers, since smaller number of states
will have READ marks.
Do you have a test case for this by any chance?

Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
