From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Thu, 15 May 2014 09:04:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D172462C9@AcuExch.aculab.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
	 <20140514132922.GA24104@mikrodark.usersys.redhat.com>
	 <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
 <1400084983.19788.15.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	"Andy Gospodarek" <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: 'Joe Perches' <joe@perches.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58417 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751000AbaEOJEV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:04:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10092-09 for <netdev@vger.kernel.org>;
 Thu, 15 May 2014 10:04:10 +0100 (BST)
In-Reply-To: <1400084983.19788.15.camel@joe-AO725>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches
> On Wed, 2014-05-14 at 09:10 -0700, Alexei Starovoitov wrote:
> > from compiler point of view it's actually easier to deal with inline functions
> > than macros. I'd suggest to do the full conversion the other way around:
> > convert all macros to static inline. Developers will enjoy better type safety
> > and compiler will enjoy more opportunities to optimize code.
> 
> Agree about the type safety, but sometimes a compiler will
> generate worse code with static inlines than #defines.

Sometimes yes - mainly because the #define version happens
at a much earlier stage in the compilation so is subject
to additional optimisations.
For most functions it either has no effect, or doesn't matter.

If you are trying to squeeze out every last unwanted clock cycle
then #defines can help.
Take the following real example:

#define ASM_COMMENT(text) asm volatile( "#" text " line " STR(__LINE__) :: )
#define hdlc_put_ind(rx_hdlc) do { \
        (++hdlc_ind_next - 1)->hi_rqst = rx_hdlc; \
        if (predict_false(hdlc_ind_next == hdlc_ind_last)) { \
            hdlc_ind_next = hdlc_ind; \
            ASM_COMMENT("ring wrapped"); \
        } \
    } while (0)

The ASM_COMMENT here is important - it stops gcc tail merging the
call in code like:
	if (foo) {
		...
		hdlc_put_ind(bar);
	} else {
		...
		hdlc_put_ind(baz);
	}
	continue;

With an inline function you can't force two copies be generated.

But most of the network stack isn't optimised to that level!

	David
