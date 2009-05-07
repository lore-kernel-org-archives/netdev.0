From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 7 May 2009 08:09:01 -0600
Message-ID: <fa686aa40905070709r7478837fnefb094d46f03ae0e@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<1241640919-4650-3-git-send-email-wd@denx.de>
	<fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
	<20090506220119.7322783420E8@gemini.denx.de>
	<fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com>
	<20090506224134.83F1583420E8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Piotr Ziecik <kosmo@semihalf.com>, Detlev Zundel <dzu@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	John Rigby <jrigby@freescale.com>
To: Wolfgang Denk <wd@denx.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090506224134.83F1583420E8@gemini.denx.de>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, May 6, 2009 at 4:41 PM, Wolfgang Denk <wd@denx.de> wrote:
> Dear Grant,
>
> In message <fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com> =
you wrote:
>>
>> > Agreed that it's ugly, but duplicatio9ng the code would have been even
>> > worse. I don't think that it has multiplatform - at least not as long
>> > as you don't ask for one image that runs on 83xx and on 512x.
>>
>> Actually, I *am* asking for one image that runs on 83xx, 52xx and
>> 521x. =A0I already can and do build and test a single image which boots
>> on all my 52xx boards, on my 8349 board, and on my G4 Mac.
>
> He. I was afraid you'd say that ;-)
>
> In this case I need a helping hand as I can't figure out how to make
> this work. Any suggestions?

Hmmm, it is rather ugly because the layout of fec_t is so different.
Easiest solution would be to duplicate the driver in its entirety, but
as you say it results in a lot of duplicate code.  It might be the
lesser of many weevils though.

Second easiest would be to factor out all the common code in the
driver into a separate .c file that gets included by a 'wrapper' .c
file for each config which first includes the correct definition of
fec_t.  This approach solves the duplicate code problem, but it also
fell out of the ugly tree and hit every branch on the way down.

ie: the wrappers would look something like this:

fs_enet_cpm1.c:
#include <asm/cpm1.h>
#include "fs_enet_main.c"

fs_enet_cpm2.c:
#include <asm/cpm2.h>
#include "fs_enet_main.c"

fs_enet_512x.c:
#include <asm/mpc512x.h>
#include "fs_enet_main.c"

And then the makefile would be something along the lines of:
obj-${CONFIG_FS_ENET_CPM1_ +=3D fs_enet_cpm1.o
obj-${CONFIG_FS_ENET_CPM2_ +=3D fs_enet_cpm2.o
obj-${CONFIG_FS_ENET_MPC512x_ +=3D fs_enet_512x.o

A brief look at the driver suggests that access to the fec_t structure
is restricted to the fec-mii.c and mac-fec.c files.  It might be
appropriate to duplicate just those files and do some form of
fs_enet_ops to select between them.

While on the topic, it looks to me like the driver could really use
some refactoring love.  Having multiple definitions of "fec_t" is
confusing and potentially lead to hard to find bugs if the wrong
header gets included by anyone.  I'd like to see all the fec specific
stuff in arch/powerpc/include/asm moved into drivers/net/fs_enet and
renamed to reflect the hardware it is associate with.  Stuff like
"fec_t" is far to generic, not to mention that typedefs are
discouraged now.

Regardless, I feel your pain.  It is not a pretty situation.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
