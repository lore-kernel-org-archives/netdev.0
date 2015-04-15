From: Joe Perches <joe@perches.com>
Subject: CodingStyle parenthesis alignment: was: Re: align to open paren
Date: Wed, 15 Apr 2015 14:06:37 -0700
Message-ID: <1429131997.2850.15.camel@perches.com>
References: <40F65EF2B5E2254199711F58E3ACB84D781CD892@MX104CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "apw@canonical.com" <apw@canonical.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Hubbe, Allen" <Allen.Hubbe@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0018.hostedemail.com ([216.40.44.18]:52152 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756462AbbDOVGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 17:06:43 -0400
In-Reply-To: <40F65EF2B5E2254199711F58E3ACB84D781CD892@MX104CL02.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 20:34 +0000, Hubbe, Allen wrote:
> Hello Andy, Joe,

Hello Allen.

As this is a discussion better suited for linux
development lists I've cc'd LKML and netdev.

> I would like to find the origin of the decision to align to the open
> paren in Linux.

Mostly it's a style decision shared by net/ and
drivers/net/ and a few other directories.

It's a checkpatch --strict only test so it's not on
by default except in net/ and drivers/net/.

> I found the commit where this was added a few years ago, d1fe9c0.
> The email thread just says the style should be that way, but not why
> or how the decision was made.  The how and the why is what I'm after,
> since I have a critique of the chosen style.
> 
> I realize there is a lot of code written using this stile, and
> changing it would be disruptive.  I certainly would not ask for that.
> 
> Indenting to the open paren might cause ambiguous indentation between
> the parenthesized expression and the next logical thing.  In the
> following, next_thing aligns to the same column as baz, even though
> baz is part of the condition expression, and next_thing is the
> continued statement.
> 
> = if (foo(bar,
> =         baz))
> =         next_thing();
> 
> It would be necessary to reindent to maintain style, even though the
> code of the next lines is the same.  This has consequences like
> changing the blame, for instance.  In the following, 4 + 5 is the bug,
> but whoever replaced the global with an instance variable gets the
> blame.

blame is overrated.
git blame -w ignores most of the whitespace noise.

> = global_variable = foo(bar,
> =                       baz(1 + 3),
> =                       baz(4 + 5) + 6);
> with
> = obj->var = foo(bar,
> =                baz(1 + 3),
> =                baz(4 + 5) + 6);
> 
> I'm used to the default in many editors, which is to indent twice
> following each open paren, as opposed to once following each open
> brace or continued statement.  It is a simpler rule for automatic
> formatting to implement.  It also avoids mixing tabs and spaces, the
> spacing is unambiguous, and to maintain style, there is no need to
> re-indent lines following an edit if the position of the open paren
> changes.
> 
> It's interesting to me that this style is only enforced by
> checkpatch.pl --strict.  It is not in Documents/CodingStyle.  That
> being the case, would it be acceptable to relax the rule in
> checkpatch.pl to accept either style?  If not, well, I'll just accept
> the chosen style and fix my code.

I personally don't care much either way.

> If the following looks acceptable to you, I'll submit the patch to the
> list.

The patch most likely wouldn't be appropriate for
net/ and drivers/net/ where the developers seem to
strongly prefer alignment to open parenthesis.

Also I think the open parenthesis count isn't right
as it would ask for multiple indents for code like:

	if ((foo(bar)) &&
	    (baz(bar))) {

I think checkpatch would now want:

	if ((foo(bar)) &&
					(baz(bar))) {

and the --fix option would be wrong too.

cheers, Joe

> Thanks,
> Allen
> 
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index d124359..8e49125 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -1834,6 +1834,15 @@ sub pos_last_openparen {
>         return length(expand_tabs(substr($line, 0, $last_openparen))) + 1;
>  }
> 
> +sub count_openparen {
> +       my ($line) = @_;
> +
> +       my $opens = $line =~ tr/\(/\(/;
> +       my $closes = $line =~ tr/\)/\)/;
> +
> +       return $opens - $closes;
> +}
> +
>  sub process {
>         my $filename = shift;
> 
> @@ -2539,11 +2548,16 @@ sub process {
>                                         " "  x ($pos % 8);
>                                 my $goodspaceindent = $oldindent . " "  x $pos;
> 
> +                               my $goodtwotabindent = $oldindent .
> +                                       "\t\t" x count_openparen($rest);
> +
>                                 if ($newindent ne $goodtabindent &&
> -                                   $newindent ne $goodspaceindent) {
> +                                   $newindent ne $goodspaceindent &&
> +                                   $newindent ne $goodtwotabindent) {
> 
>                                         if (CHK("PARENTHESIS_ALIGNMENT",
> -                                               "Alignment should match open parenthesis\n" . $hereprev) &&
> +                                               "Alignment should match open parenthesis, " .
> +                                               "or be twice indented for each open parenthesis\n" . $hereprev) &&
>                                             $fix && $line =~ /^\+/) {
>                                                 $fixed[$fixlinenr] =~
>                                                     s/^\+[ \t]*/\+$goodtabindent/;
