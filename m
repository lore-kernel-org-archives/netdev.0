From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Wed, 14 May 2014 14:52:00 -0700
Message-ID: <CAADnVQ+6-KQRRLS6Nos7u1J1BA9KoS6bJFAsnWE6d4vC010Djg@mail.gmail.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
	<20140514132922.GA24104@mikrodark.usersys.redhat.com>
	<CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
	<1400084983.19788.15.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Veaceslav Falico <vfalico@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:50180 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbaENVwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 17:52:01 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so342572qgd.1
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 14:52:00 -0700 (PDT)
In-Reply-To: <1400084983.19788.15.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 9:29 AM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-05-14 at 09:10 -0700, Alexei Starovoitov wrote:
>> from compiler point of view it's actually easier to deal with inline functions
>> than macros. I'd suggest to do the full conversion the other way around:
>> convert all macros to static inline. Developers will enjoy better type safety
>> and compiler will enjoy more opportunities to optimize code.
>
> Agree about the type safety, but sometimes a compiler will
> generate worse code with static inlines than #defines.

yep, sometimes compiler heuristics of size increase due to inline vs
cost of call
vs further optimizations after inline are guessing things wrong.
always_inline can force it in such cases.
Online articles about macro vs static inline mainly talk about
inlining and type safety.
I'm trying to make a point that there is more to it from compiler point of view.
'static inline' approach changes the scope of arguments whereas macro
pushes code into the scope of callsite.
Here is a synthetic example:
struct S {
  int v1;
  int v2;
  int v3;
};
static inline void f(struct S *s)
{
  s->v1 = 0;
  s->v2 = 0;
  s->v3 = 0;
}
#define F(s) \
  ({ \
     s->v1 = 0; \
     s->v2 = 0; \
     s->v3 = 0; \
   })

struct S *s1;
void test1()
{
  f(s1);
}
void test2()
{
  F(s1);
}
$ gcc -O2 -S  -fno-strict-aliasing
test1:
        movq    s1(%rip), %rax
        movl    $0, (%rax)
        movl    $0, 4(%rax)
        movl    $0, 8(%rax)
        ret
test2:
        movq    s1(%rip), %rax
        movl    $0, (%rax)
        movq    s1(%rip), %rax
        movl    $0, 4(%rax)
        movq    s1(%rip), %rax
        movl    $0, 8(%rax)
        ret

I cannot imagine the case where macro would be faster than static inline
unless it wasn't inlined.
