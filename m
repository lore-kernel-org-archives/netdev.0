From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: fib_trie: commit 95f60ea3e99a missing else?
Date: Fri, 03 Apr 2015 17:32:43 -0700
Message-ID: <551F312B.9010104@gmail.com>
References: <1428094382.29510.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34375 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbbDDAcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 20:32:45 -0400
Received: by pdbni2 with SMTP id ni2so136736417pdb.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 17:32:44 -0700 (PDT)
In-Reply-To: <1428094382.29510.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2015 01:53 PM, Joe Perches wrote:
> Hello Alexander.
> 
> commit 95f60ea3e99a ("fib_trie: Add collapse() and should_collapse() to resize")
> changed this block from:
> 
> 	if (a && !b)
> 		...
> 	else if (!a && b)
> 		...
> 
> to:
> 
> 	if (a && !b)
> 		...
> 	if (!a && b)
> 		... 
> 
> Was there a reason for the "else" removal?

Because it was ugly and unnecessary.  The two cases are already mutually
exclusive, and it isn't as if the value of a or b changes between the
tests.  GCC is usually smart enough to realize this so when it tests a
it will either continue with the !b check or switch to the other
statement and check for b being set.

> I notice that object code size increases a bit (x86-64)
> if the else is put back.

It is likely because it is checking for (a or !b) and then coming back
around and checking for (!a && b) when you add the else.  I have found
that GCC is fairly smart in terms of checks so there isn't much
advantage to using an else if two tests are mutually exclusive.

> net/ipv4/fib_trie.c
> []
> @@ -375,11 +388,11 @@ static void put_child(struct tnode *tn, unsigned long i, s
>  
>         BUG_ON(i >= tnode_child_length(tn));
>  
> -       /* update emptyChildren */
> +       /* update emptyChildren, overflow into fullChildren */
>         if (n == NULL && chi != NULL)
> -               tn->empty_children++;
> -       else if (n != NULL && chi == NULL)
> -               tn->empty_children--;
> +               empty_child_inc(tn);
> +       if (n != NULL && chi == NULL)
> +               empty_child_dec(tn);
> 

The "else" was an unnecessary optimization since this isn't really
fast-path code and the compiler is usually smart enough to understand
that depending on the value of n it is either going to test for
increment or decrement by testing the value of chi.

You could probably do an objdump of the function to better understand
the difference of one versus the other.  I suspect at worst what is
happening is that the check for !n is being dropped and the logic for
chi != NULL is just flowing through and performing one additional test
on chi before jumping past the empty_child_dec.

- Alex
