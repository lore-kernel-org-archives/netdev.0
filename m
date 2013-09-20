From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Fri, 20 Sep 2013 12:24:38 -0700
Message-ID: <CAGXu5jLENb+x6b9XOY7-pWMT7GsFgnLr0=A8VNFLkqMi0BX4=w@mail.gmail.com>
References: <CAGXu5jL+NeBw2_vXymM81UdtS6UO7KZA2S4rf3gwM_7nSJ2h6g@mail.gmail.com>
	<20130917205742.16147.qmail@science.horizon.com>
	<201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>
	<CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
	<201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
	<523C0268.20404@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@openvz.org>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, George Spelvin <linux@horizon.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Jan Beulich <JBeulich@suse.com>, Joe Perches <joe@perches.com>,
	Motohiro KOSAKI <kosaki.motohiro@gmail.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <523C0268.20404@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 20, 2013 at 1:08 AM, Jiri Slaby <jslaby@suse.cz> wrote:
> On 09/20/2013 06:09 AM, Tetsuo Handa wrote:
>> --- a/fs/proc/consoles.c
>> +++ b/fs/proc/consoles.c
> ...
>> @@ -47,11 +46,10 @@ static int show_console_dev(struct seq_file *m, void *v)
>>                       con_flags[a].name : ' ';
>>       flags[a] = 0;
>>
>> -     seq_printf(m, "%s%d%n", con->name, con->index, &len);
>> -     len = 21 - len;
>> -     if (len < 1)
>> -             len = 1;
>> -     seq_printf(m, "%*c%c%c%c (%s)", len, ' ', con->read ? 'R' : '-',
>> +     seq_setwidth(m, 21 - 1);
>> +     seq_printf(m, "%s%d", con->name, con->index);
>> +     seq_pad(m, ' ');
>> +     seq_printf(m, "%c%c%c (%s)", con->read ? 'R' : '-',
>>                       con->write ? 'W' : '-', con->unblank ? 'U' : '-',
>>                       flags);
>
> Hello, do you really need seq_setwidth? It makes it really ugly...

There are a few problems that have been discussed on the various
threads. Namely, we want to minimize the changes to the seq_file
structure and to not add additional work to all the seq_file users
that don't care about padding. If the seq_file calls always track how
far they're written across each call, we add unneeded work to all the
users. To avoid this, we must identify to the seq_file subsystem where
we want to start tracking the length written. To allow this to be
spread across multiple calls (something the %n can't do), we must
record seq->count at some point, and then compare against it at the
point where we want to perform padding.

> Or do we need that all? Couldn't we simply have seq_printf_padded? Or
> maybe some % modifier in seq_printf to pad the string?

Adding a _padding version of things means we'd have to add it to all
seq_* function that print things (like printing paths, etc). Using
this method, the output doesn't matter. We declare the starting point,
output whatever we need, then perform padding, and continue writing.

I think the declaration/output/pad method seems the least invasive to
existing users of padding, and the highest level of flexibility going
forward for future users.

>> --- a/net/ipv4/fib_trie.c
>> +++ b/net/ipv4/fib_trie.c
> ...
>> @@ -2548,15 +2549,15 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
>>                                        (fi->fib_advmss ?
>>                                         fi->fib_advmss + 40 : 0),
>>                                        fi->fib_window,
>> -                                      fi->fib_rtt >> 3, &len);
>> +                                      fi->fib_rtt >> 3);
>>                       else
>>                               seq_printf(seq,
>>                                        "*\t%08X\t%08X\t%04X\t%d\t%u\t"
>> -                                      "%d\t%08X\t%d\t%u\t%u%n",
>> +                                      "%d\t%08X\t%d\t%u\t%u",
>>                                        prefix, 0, flags, 0, 0, 0,
>> -                                      mask, 0, 0, 0, &len);
>> +                                      mask, 0, 0, 0);
>>
>> -                     seq_printf(seq, "%*s\n", 127 - len, "");
>> +                     seq_pad(seq, '\n');
>
> Hmm, seq_pad is unintuitive. I would say it pads the string by '\n'. Of
> course it does not, but...

I don't think this is a very serious problem. Currently, the padding
character is always ' ' for all existing callers, so it only makes
sense to make the trailing character an argument.

-Kees

-- 
Kees Cook
Chrome OS Security
