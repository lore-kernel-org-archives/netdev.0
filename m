From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 01/16] add basic register-field manipulation macros
Date: Mon, 29 Aug 2016 17:40:10 +0200
Message-ID: <57C4575A.9090008@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>    <1472234775-29453-2-git-send-email-jakub.kicinski@netronome.com>        <57C447F1.60807@iogearbox.net> <20160829170739.2aab0893@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47302 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933326AbcH2PkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 11:40:14 -0400
In-Reply-To: <20160829170739.2aab0893@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2016 05:07 PM, Jakub Kicinski wrote:
> On Mon, 29 Aug 2016 16:34:25 +0200, Daniel Borkmann wrote:
>> On 08/26/2016 08:06 PM, Jakub Kicinski wrote:
>>> Common approach to accessing register fields is to define
>>> structures or sets of macros containing mask and shift pair.
>>> Operations on the register are then performed as follows:
>>>
>>>    field = (reg >> shift) & mask;
>>>
>>>    reg &= ~(mask << shift);
>>>    reg |= (field & mask) << shift;
>>>
>>> Defining shift and mask separately is tedious.  Ivo van Doorn
>>> came up with an idea of computing them at compilation time
>>> based on a single shifted mask (later refined by Felix) which
>>> can be used like this:
>>>
>>>    #define REG_FIELD 0x000ff000
>>>
>>>    field = FIELD_GET(REG_FIELD, reg);
>>>
>>>    reg &= ~REG_FIELD;
>>>    reg |= FIELD_PREP(REG_FIELD, field);
>>>
>>> FIELD_{GET,PREP} macros take care of finding out what the
>>> appropriate shift is based on compilation time ffs operation.
>>>
>>> GENMASK can be used to define registers (which is usually
>>> less error-prone and easier to match with datasheets).
>>>
>>> This approach is the most convenient I've seen so to limit code
>>> multiplication let's move the macros to a global header file.
>>> Attempts to use static inlines instead of macros failed due
>>> to false positive triggering of BUILD_BUG_ON()s, especially with
>>> GCC < 6.0.
>>>
>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> [...]
>>> + * Bitfield access macros
>>> + *
>>> + * FIELD_{GET,PREP} macros take as first parameter shifted mask
>>> + * from which they extract the base mask and shift amount.
>>> + * Mask must be a compilation time constant.
>>> + *
>>> + * Example:
>>> + *
>>> + *  #define REG_FIELD_A  GENMASK(6, 0)
>>> + *  #define REG_FIELD_B  BIT(7)
>>> + *  #define REG_FIELD_C  GENMASK(15, 8)
>>> + *  #define REG_FIELD_D  GENMASK(31, 16)
>>> + *
>>> + * Get:
>>> + *  a = FIELD_GET(REG_FIELD_A, reg);
>>> + *  b = FIELD_GET(REG_FIELD_B, reg);
>>> + *
>>> + * Set:
>>> + *  reg = FIELD_PREP(REG_FIELD_A, 1) |
>>> + *	  FIELD_PREP(REG_FIELD_B, 0) |
>>> + *	  FIELD_PREP(REG_FIELD_C, c) |
>>> + *	  FIELD_PREP(REG_FIELD_D, 0x40);
>>> + *
>>> + * Modify:
>>> + *  reg &= ~REG_FIELD_C;
>>> + *  reg |= FIELD_PREP(REG_FIELD_C, c);
>>> + */
>>> +
>>> +#define _bf_shf(x) (__builtin_ffsll(x) - 1)
>>> +
>>> +#define _BF_FIELD_CHECK(_mask, _reg, _val, _pfx)			\
>>
>> Nit: if possible, please always use "__" instead of "_" as prefix, which is
>> more common coding style in the kernel.
>
> I went with single underscore, because my understanding was:
>   - no underscore - safe, "user-facing" API;
>   - two underscores - internal, make sure you know how to use it;
>   - single underscore - library internals, shouldn't be touched.

That convention would be new to me, at least I haven't seen it much (see
also recent comment on the act_tunnel set). Still think two underscores
is generally preferred (unless this is somewhere documented otherwise).

> I don't expect anyone to invoke those macros, the underscore is
> there to avoid collisions.
>
>>> +	({								\
>>> +		BUILD_BUG_ON_MSG(!__builtin_constant_p(_mask),		\
>>> +				 _pfx "mask is not constant");		\
>>> +		BUILD_BUG_ON_MSG(!(_mask), _pfx "mask is zero");	\
>>> +		BUILD_BUG_ON_MSG(__builtin_constant_p(_val) ?		\
>>> +				 ~((_mask) >> _bf_shf(_mask)) & (_val) : 0, \
>>> +				 _pfx "value too large for the field"); \
>>> +		BUILD_BUG_ON_MSG((_mask) > (typeof(_reg))~0ull,		\
>>> +				 _pfx "type of reg too small for mask"); \
>>> +		__BUILD_BUG_ON_NOT_POWER_OF_2((_mask) +			\
>>> +					      (1ULL << _bf_shf(_mask))); \
>>> +	})
>>> +
>>> +/**
>>> + * FIELD_PREP() - prepare a bitfield element
>>> + * @_mask: shifted mask defining the field's length and position
>>> + * @_val:  value to put in the field
>>> + *
>>> + * FIELD_PREP() masks and shifts up the value.  The result should
>>> + * be combined with other fields of the bitfield using logical OR.
>>> + */
>>> +#define FIELD_PREP(_mask, _val)						\
>>> +	({								\
>>> +		_BF_FIELD_CHECK(_mask, 0ULL, _val, "FIELD_PREP: ");	\
>>> +		((typeof(_mask))(_val) << _bf_shf(_mask)) & (_mask);	\
>>> +	})
>>> +
>>> +/**
>>> + * FIELD_GET() - extract a bitfield element
>>> + * @_mask: shifted mask defining the field's length and position
>>> + * @_reg:  32bit value of entire bitfield
>>> + *
>>> + * FIELD_GET() extracts the field specified by @_mask from the
>>> + * bitfield passed in as @_reg by masking and shifting it down.
>>> + */
>>> +#define FIELD_GET(_mask, _reg)						\
>>> +	({								\
>>> +		_BF_FIELD_CHECK(_mask, _reg, 0U, "FIELD_GET: ");	\
>>> +		(typeof(_mask))(((_reg) & (_mask)) >> _bf_shf(_mask));	\
>>> +	})
>>
>> No strong opinion, but FIELD_PREP() sounds a bit weird. Maybe rather a
>> FIELD_GEN() (aka "generate") and FIELD_GET() pair?
>
> FWIW PREP was suggested by Linus:
>
> https://lkml.org/lkml/2016/8/17/384

Hmm, ok, fair enough.

>>> +#endif
>>> diff --git a/include/linux/bug.h b/include/linux/bug.h
>>> index e51b0709e78d..292d6a10b0c2 100644
>>> --- a/include/linux/bug.h
>>> +++ b/include/linux/bug.h
>>> @@ -13,6 +13,7 @@ enum bug_trap_type {
>>>    struct pt_regs;
>>>
>>>    #ifdef __CHECKER__
>>> +#define __BUILD_BUG_ON_NOT_POWER_OF_2(n) (0)
>>>    #define BUILD_BUG_ON_NOT_POWER_OF_2(n) (0)
>>>    #define BUILD_BUG_ON_ZERO(e) (0)
>>>    #define BUILD_BUG_ON_NULL(e) ((void*)0)
>>> @@ -24,6 +25,8 @@ struct pt_regs;
>>>    #else /* __CHECKER__ */
>>>
>>>    /* Force a compilation error if a constant expression is not a power of 2 */
>>> +#define __BUILD_BUG_ON_NOT_POWER_OF_2(n)	\
>>> +	BUILD_BUG_ON(((n) & ((n) - 1)) != 0)
>>
>> Is there a reason BUILD_BUG_ON_NOT_POWER_OF_2(n) cannot be reused?
>>
>> Because the (n) == 0 check would trigger (although it shouldn't ...)?
>
> It would, I'm doing:
>    mask + lowest bit of mask
> which will result in:
>    highest bit of mask << 1
> which in turn will overflow for masks with highest bit set.

Ahh, right.
