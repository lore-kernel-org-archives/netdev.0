From: "Hannes Eder" <hannes@hanneseder.net>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a compound statement
Date: Mon, 29 Dec 2008 15:35:31 +0100
Message-ID: <154e089b0812290635o5792af25jd26fa184a02dc7af@mail.gmail.com>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	 <20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
	 <m3hc4voo2a.fsf@maximus.localdomain>
	 <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
	 <m3ocz2ua3w.fsf@maximus.localdomain> <1230053186.1447.9.camel@brick>
	 <m3k59qssix.fsf@maximus.localdomain>
	 <alpine.LFD.2.00.0812231008350.3535@localhost.localdomain>
	 <m3hc4usco9.fsf@maximus.localdomain>
	 <alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Halasa" <khc@pm.waw.pl>,
	"Harvey Harrison" <harvey.harrison@gmail.com>,
	"=?ISO-8859-1?Q?H=E5kon_L=F8vdal?=" <hlovdal@gmail.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:3073 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbYL2Ofe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 09:35:34 -0500
In-Reply-To: <alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 12:38 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Wed, 24 Dec 2008, Krzysztof Halasa wrote:
>>
>> So is a case like
>>       do
>>               x;
>>       while (y);
>> It can't be made more clear with brackets.
>
> Oh yes it can. People look at that, and it's so uncommon that they
> literally believe it is a mis-indent.
>
> [snip]
>
>> kmalloc(sizeof i) just doesn't look good, the operator looks like
>> a variable name.
>
> And I agree with you. "sizeof i" doesn't look good. It's uncommon, and
> doesn't match peoples expectations.
>
>> But there is this return statement. Some people tend to write
>> return (x); I simply write return x;
>
> I do to. And it's the common thing to do, and only totally confused people
> think that 'return' is a somehow remotely like a "function" of its
> arguments (the way 'sizeof' is - sizeof _is_ a function of its arguments,
> albeit a very rare one).
>
>> It's clear, and so is a simple do-while.
>
> No. "return x;" is clear because it's the common thing, which means that
> peopel are good at reading it.

I got curious and conducted a little experiment, here is the outcome
for the linux-2.6 kernel tree:

hannes@vmbox:~/linux-2.6$ find . -name "*.[ch]" -print0 | xargs -0 cat
| ../sparse/cstats -

stats for '-':
  do's:         8092, non compound:              79 (  1.0%)
  sizeof's:    51216, without parenthesis:     1543 (  3.0%)
  return's:   286167, with parenthesis:       13552 (  4.7%)

'cstats' is a little program I wrote using the sparse library, see below.

The value for "return's with parenthesis" is a bit of an estimation,
as 'cstats' operates only at the token level, so
"return (x) ? y : z;" counts as "return with parenthesis".

some sanity checks, to ensure the magnitudes are right:

hannes@vmbox:~/linux-2.6$ git grep -w do -- *.[ch] | wc -l
20599

hannes@vmbox:~/linux-2.6$ git grep '\bdo[ \t]*{' -- *.[ch] | wc -l
7805

I assume 'do' is used frequently in comments:

hannes@vmbox:~/linux-2.6$ git grep '\*.*\bdo\b' -- *.[ch] | wc -l
11358

hannes@vmbox:~/linux-2.6$ git grep '^[ \t]*do$' -- *.[ch] | wc -l
34

hannes@vmbox:~/linux-2.6$ git grep -w sizeof -- *.[ch] | wc -l
49631

constructs like sizeof(array)/sizeof(array[0]) or common:

hannes@vmbox:~/linux-2.6$ git grep  'sizeof.*sizeof' -- *.[ch] | wc -l
1827

hannes@vmbox:~/linux-2.6$ git grep '\bsizeof [^(]' -- *.[ch] | wc -l
1534

hannes@vmbox:~/linux-2.6$ git grep -w return -- *.[ch] | wc -l
295304

hannes@vmbox:~/linux-2.6$ git grep '\breturn (' -- *.[ch] | wc -l
11067

Best,
Hannes


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#include "token.h"
#include "parse.h"

int main(int argc, char **argv)
{
        struct string_list *filelist = NULL;
        char *filename;

        sparse_initialize(argc, argv, &filelist);
        FOR_EACH_PTR_NOTAG(filelist, filename) {
                int fd;
                struct token *token;
                int do_stats = 0;
                int do_stats_nc = 0;
                int sizeof_exprs = 0;
                int sizeof_exprs_np = 0;
                int return_stats = 0;
                int return_stats_wp = 0;

                if (strcmp(filename, "-") == 0) {
                        fd = 0;
                } else {
                        fd = open(filename, O_RDONLY);
                        if (fd < 0)
                                die("No such file: %s", filename);
                }

                // Tokenize the input stream
                token = tokenize(filename, fd, NULL, includepath);
                close(fd);

                for ( ; !eof_token(token); token = token->next) {
                        if (token_type(token) == TOKEN_IDENT) {
                                if (token->ident == &do_ident) {
                                        do_stats++;
                                        if (!match_op(token->next, '{'))
                                                do_stats_nc++;
                                }
                                else if (token->ident == &sizeof_ident) {
                                        sizeof_exprs++;
                                        if (!match_op(token->next, '('))
                                                sizeof_exprs_np++;
                                }
                                else if (token->ident == &return_ident) {
                                        return_stats++;
                                        if (match_op(token->next, '('))
                                                return_stats_wp++;
                                }
                        }
                }

                printf("stats for '%s':\n", filename);
                printf("  do's:     %8d, non compound:        %8d (%5.1f%%)\n",
                       do_stats, do_stats_nc,
                       100.0 * do_stats_nc / (do_stats?:1) );
                printf("  sizeof's: %8d, without parenthesis: %8d (%5.1f%%)\n",
                       sizeof_exprs, sizeof_exprs_np,
                       100.0 * sizeof_exprs_np / (sizeof_exprs?:1) );
                printf("  return's: %8d, with parenthesis:    %8d (%5.1f%%)\n",
                       return_stats, return_stats_wp,
                       100.0 * return_stats_wp / (return_stats?:1) );

        } END_FOR_EACH_PTR_NOTAG(filename);
        return 0;
}
