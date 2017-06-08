From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 4/5] bpf/verifier: track
 signed and unsigned min/max values
Date: Thu, 8 Jun 2017 16:23:24 +0100
Message-ID: <abee6b82-316b-58cb-fa85-0584866f8d29@solarflare.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<56b924eb-e2d5-b2ee-484a-d073a3b13d79@solarflare.com>
	<20170608024036.xsgbqghn6kqrk2cr@ast-mbp>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20170608024036.xsgbqghn6kqrk2cr@ast-mbp>
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

On 08/06/17 03:40, Alexei Starovoitov wrote:
> On Wed, Jun 07, 2017 at 03:59:25PM +0100, Edward Cree wrote:
>> Allows us to, sometimes, combine information from a signed check of one
>>  bound and an unsigned check of the other.
>> We now track the full range of possible values, rather than restricting
>>  ourselves to [0, 1<<30) and considering anything beyond that as
>>  unknown.  While this is probably not necessary, it makes the code more
>>  straightforward and symmetrical between signed and unsigned bounds.
>>
>> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
>> ---
>>  include/linux/bpf_verifier.h |  22 +-
>>  kernel/bpf/verifier.c        | 661 +++++++++++++++++++++++++------------------
>>  2 files changed, 395 insertions(+), 288 deletions(-)
>>
>> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
>> index e341469..10a5944 100644
>> --- a/include/linux/bpf_verifier.h
>> +++ b/include/linux/bpf_verifier.h
>> @@ -11,11 +11,15 @@
>>  #include <linux/filter.h> /* for MAX_BPF_STACK */
>>  #include <linux/tnum.h>
>>  
>> - /* Just some arbitrary values so we can safely do math without overflowing and
>> -  * are obviously wrong for any sort of memory access.
>> -  */
>> -#define BPF_REGISTER_MAX_RANGE (1024 * 1024 * 1024)
>> -#define BPF_REGISTER_MIN_RANGE -1
>> +/* Maximum variable offset umax_value permitted when resolving memory accesses.
>> + * In practice this is far bigger than any realistic pointer offset; this limit
>> + * ensures that umax_value + (int)off + (int)size cannot overflow a u64.
>> + */
>> +#define BPF_MAX_VAR_OFF	(1ULL << 31)
>> +/* Maximum variable size permitted for ARG_CONST_SIZE[_OR_ZERO].  This ensures
>> + * that converting umax_value to int cannot overflow.
>> + */
>> +#define BPF_MAX_VAR_SIZ	INT_MAX
>>  
>>  struct bpf_reg_state {
>>  	enum bpf_reg_type type;
>> @@ -38,7 +42,7 @@ struct bpf_reg_state {
>>  	 * PTR_TO_MAP_VALUE_OR_NULL, we have to NULL-check it _first_.
>>  	 */
>>  	u32 id;
>> -	/* These three fields must be last.  See states_equal() */
>> +	/* These five fields must be last.  See states_equal() */
>>  	/* For scalar types (SCALAR_VALUE), this represents our knowledge of
>>  	 * the actual value.
>>  	 * For pointer types, this represents the variable part of the offset
>> @@ -51,8 +55,10 @@ struct bpf_reg_state {
>>  	 * These refer to the same value as align, not necessarily the actual
>>  	 * contents of the register.
>>  	 */
>> -	s64 min_value; /* minimum possible (s64)value */
>> -	u64 max_value; /* maximum possible (u64)value */
>> +	s64 smin_value; /* minimum possible (s64)value */
>> +	s64 smax_value; /* maximum possible (s64)value */
>> +	u64 umin_value; /* minimum possible (u64)value */
>> +	u64 umax_value; /* maximum possible (u64)value */
> have uneasy feeling about this one.
> It's 16 extra bytes to be stored in every reg_state and memcmp later
> while we didn't have cases where people wanted negative values
> in ptr+var cases. Why bother than?
It was the only way I could see to both pass my new test (correctly reject
 an uninformative combination of JGT and JSGT), and still pass one of the
 other tests where we have to accept an informative combination of JGT and
 JSGT.  This isn't so much about supporting negative numbers as it is about
 deducing the right bounds from signed checks, or a mixture of signed and
 unsigned checks on the same value.
For instance, if you check a register is s< 5, you know nothing yet about
 its unsigned maximum (it could be -1).  But if you then check it's u< 10,
 or even if you check it's s>= 0, you've now learned its sign bit so you
 can conclude from the previous check that it's u< 5.  But to conclude
 that, you have to have stored the bound from the previous check.
I'm not too worried about the extra 16 bytes, because this is a control-
 plane operation, and I'd be surprised if its performance really turned out
 to be a problem.  But if there's a better way to handle these checks, I'm
 all ears.
>>  unknown.  While this is probably not necessary, it makes the code more
>>  straightforward and symmetrical between signed and unsigned bounds.
> it's hard for me to see the 'straightforward' part yet.
Well, the new reg_set_min_max[_inv]() are simpler, as they just update the
 relevant bound then call __reg_deduce_bounds() to propagate that knowledge
 into the others, rather than having confusing (and, as we've seen, buggy)
 logic in each case about "if we did this kind of check we've learned that
 thing in this branch".
Also, all the care to check "did we exceed BPF_REGISTER_MAX_RANGE?" goes
 away, as does special handling of negatives to turn them into
 BPF_REGISTER_MIN_RANGE (again, this has bugs in the current code).  Instead
 we just have to check "does our operation on the bounds overflow?", and if
 so, mark our bounds as unknown.
I think a lot of the arithmetic ops become a more mechanical "does this
 overflow?  No?  Then let's compute new bounds".  But then, that's partly
 because the semantics of the old min_value and max_value weren't documented
 anywhere (do they refer to the signed or the unsigned value in the
 register?) and so it's unclear to me why some of the code does what it does.

-Ed
