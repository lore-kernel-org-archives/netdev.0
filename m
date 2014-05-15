From: Joe Perches <joe@perches.com>
Subject: [PATCH] tg3: Use static inlines not macros
Date: Wed, 14 May 2014 17:04:11 -0700
Message-ID: <1400112251.12666.14.camel@joe-AO725>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
	 <20140514132922.GA24104@mikrodark.usersys.redhat.com>
	 <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
	 <1400084983.19788.15.camel@joe-AO725>
	 <CAADnVQ+6-KQRRLS6Nos7u1J1BA9KoS6bJFAsnWE6d4vC010Djg@mail.gmail.com>
	 <1400105033.30384.34.camel@joe-AO725>
	 <CAADnVQKvrL+eKNbV=OWP3h2qPmHDm5ixt_4qNDtw-DZeR8US-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0249.hostedemail.com ([216.40.44.249]:45906 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751721AbaEOAEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 20:04:15 -0400
In-Reply-To: <CAADnVQKvrL+eKNbV=OWP3h2qPmHDm5ixt_4qNDtw-DZeR8US-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer versions of gcc produce better code
so convert some macros to static inlines.

$ gcc --version
gcc (Ubuntu 4.8.2-19ubuntu1) 4.8.2
Copyright (C) 2013 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

(x86/defconfig)

$ size drivers/net/ethernet/broadcom/tg3.o.*
   text	   data	    bss	    dec	    hex	filename
 134282	    963	      0	 135245	  2104d	drivers/net/ethernet/broadcom/tg3.o.new
 134613	    963	      0	 135576	  21198	drivers/net/ethernet/broadcom/tg3.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
On Wed, 2014-05-14 at 16:37 -0700, Alexei Starovoitov wrote:
> On Wed, May 14, 2014 at 3:03 PM, Joe Perches <joe@perches.com> wrote:
> > On Wed, 2014-05-14 at 14:52 -0700, Alexei Starovoitov wrote:
> >> I cannot imagine the case where macro would be faster than static inline
> >> unless it wasn't inlined.
> >
> > For an example, look at commit 4153577a8d
> > ("tg3: Use different macros for pci_chip_rev_id accesses")
> >
> > Converting these macros to static inline produces
> > larger/slower code.  (at least with gcc 4.7.3)
> >
> > +#define tg3_chip_rev_id(tp)                                    \
> > +       ((tp)->pci_chip_rev_id)
> > +#define tg3_asic_rev(tp)                                       \
> > +       ((tp)->pci_chip_rev_id >> 12)
> > +#define tg3_chip_rev(tp)                                       \
> > +       ((tp)->pci_chip_rev_id >> 8)
> >
> 
> hmm. interesting.
> Using gcc 4.7.2 object file size is larger with 'static inline'
> 2893016 vs 2868112
> but that's due to larger debug info.
> .text is actually smaller 000207c4 vs 00020824
> and these three calls were inlined (even without __always_inline),
> so I suspect it's better optimized..
> though better optimized can very well mean slower.

Compiler optimizers change with every version too.

 drivers/net/ethernet/broadcom/tg3.h | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 461acca..3d0cf6b 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3416,11 +3416,19 @@ struct tg3 {
  *     Using statement expression macros to check tp with
  *     typecheck(struct tg3 *, tp) also creates larger objects.
  */
-#define tg3_chip_rev_id(tp)					\
-	((tp)->pci_chip_rev_id)
-#define tg3_asic_rev(tp)					\
-	((tp)->pci_chip_rev_id >> 12)
-#define tg3_chip_rev(tp)					\
-	((tp)->pci_chip_rev_id >> 8)
+static inline u32 tg3_chip_rev_id(const struct tg3 *tp)
+{
+	return tp->pci_chip_rev_id;
+}
+
+static inline u32 tg3_asic_rev(const struct tg3 *tp)
+{
+	return tp->pci_chip_rev_id >> 12;
+}
+
+static inline u32 tg3_chip_rev(const struct tg3 *tp)
+{
+	return tp->pci_chip_rev_id >> 8;
+}
 
 #endif /* !(_T3_H) */
