From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Sun, 26 Sep 2004 13:28:44 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409261224350.8973@u.domain.uli>
References: <E1CBUBF-00034F-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBUBF-00034F-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sun, 26 Sep 2004, Herbert Xu wrote:

> Well if we're doing this then we might as well keep it sorted by TOS.
> It makes the code simpler, right?

	I do not know for good reason to avoid order by TOS, may be
Dave can explain.

	As for your last change, it is wrong:

>                 prev_fa = NULL;
>                 list_for_each_entry(fa, head, fa_list) {
> -                       if (fa->fa_tos != tos)
> -                               continue;
> +                       if (fa->fa_tos < tos)

	here prev_fa can be NULL but we require to stop at fa.
It happens when we are creating first entry in our subchain.

> +                               break;
>                         prev_fa = fa;
> +                       if (fa->fa_tos > tos)
> +                               continue;
>                         if (prio <= fa->fa_info->fib_priority)
>                                 break;

	here if fa is the last one it is wrong to return prev_fa!=NULL,
we need to return NULL (append) because we have to append
new entry in our subchain (which is last in this case).

>                 }

	Here is my understanding how should work fib_find_alias (already
implemented, refer to my first posting, the case where we sort by TOS).
Note that the logic is same as before fib_alias appeared:

- fib_find_alias can return exact match: the desired TOS & PRIO.
This is the first entry in a subchain where append and prepend
matter (NLM_F_APPEND).

- the return value should be used in this way: if NULL then we have
to append the new entry at end of list. Else, it is a fa with
fa_tos<desired_TOS || (fa_tos==desired_TOS && fib_priority >= desired PRIO)
We are going to insert the new entry before this fa (even if it is
not exact match, even if it is from next subchain). Saying it in
another way: use append only if there is no place to insert.

	Sometimes we can add entry with metric less
than existing one but sometimes we have to insert new entry
between two subchains (fa points to first entry in next subchain).
The result: fa points to next subchain or somehere in our
subchain - the place to insert.

- list_add serves the purpose to insert between head and first
(fa and next fa/fn_alias), we need list_add_tail (insert before fa
or fn_alias, i.e. append at tail).

	So, may be we need my 1st version of fib_find_alias plus
'fa->fa_tos == tos' plus list_add_tail?

Regards

--
Julian Anastasov <ja@ssi.bg>
