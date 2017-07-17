From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework
 value tracking
Date: Mon, 17 Jul 2017 18:02:02 +0100
Message-ID: <fbd2b381-c444-a736-2d9e-aa83d6153178@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
	<E65DE75F-FC5F-41BC-9F7B-C03D324D8C6F@gmail.com>
	<abd3c014-f33a-6e86-aead-be38697a2cec@solarflare.com>
	<3A96914E-3009-4E19-B138-7A636A76D9C8@gmail.com>
	<68a2487e-f706-1b61-5c4c-20ffe6d51127@solarflare.com>
	<12DCE590-7F67-4639-A825-61A24AC44ED3@gmail.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Nadav Amit <nadav.amit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <12DCE590-7F67-4639-A825-61A24AC44ED3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On 12/07/17 23:07, Nadav Amit wrote:
> Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org> wrote:
>> In this specific case, there was a bug before: if (say) src and dst were
>> both unknown bytes (so range 0 to 255), it would compute the new min and max
>> to be 0, so it would think the result is known to be 0.  But that's wrong,
>> because it could be anything from -255 to +255.  The bug's implications are
>> that it could be used to construct an out-of-range offset to (say) a map
>> pointer which the verifier would think was in-range and thus accept.
> This sounds like a serious bug that may need to be backported to stable
> versions, no? In this case I would assume it should be in a separate patch
> so it could be applied separately.
Having looked deeper into this in attempting to create a test that the existing
 verifier would fail, it turns out that in the existing verifier that BPF_SUB
 handling is dead code.  If (for instance) we subtract an UNKNOWN_VALUE from a
 PTR_TO_MAP_VALUE_ADJ, that code will be run, but afterwards we will
 mark_reg_unknown_value() the register (bottom of check_alu_op()) making our
 previous min/max determination irrelevant.
So there's nothing to backport, and if I did change this in its own patch,
 there'd be no way to test it.  (I have, however, added a test covering this
 codepath in the new verifier.)

-Ed
