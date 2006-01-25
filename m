From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: e100 oops on resume
Date: Wed, 25 Jan 2006 11:37:40 -0800
Message-ID: <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>
References: <20060124225919.GC12566@suse.de>
	 <20060124232142.GB6174@inferi.kami.home>
	 <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_68443_5705500.1138217860777"
Cc: Stefan Seyfried <seife@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932141AbWAYTho@vger.kernel.org>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060125121125.GH5465@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_68443_5705500.1138217860777
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 1/25/06, Olaf Kirch <okir@suse.de> wrote:
> On Wed, Jan 25, 2006 at 10:02:40AM +0100, Olaf Kirch wrote:
> > I'm not sure what the right fix would be. e100_resume would probably
> > have to call e100_alloc_cbs early on, while e100_up should avoid
> > calling it a second time if nic->cbs_avail !=3D 0. A tentative patch
> > for testing is attached.
>
> Reportedly, the patch fixes the crash on resume.

Cool, thanks for the research, I have a concern about this however.

its an interesting patch, but it raises the question why does
e100_init_hw need to be called at all in resume?  I looked back
through our history and that init_hw call has always been there.  I
think its incorrect, but its taking me a while to set up a system with
the ability to resume.

everywhere else in the driver alloc_cbs is called before init_hw so it
just seems like a long standing bug.

comments?  anyone want to test? i compile tested this, but it is untested.

------=_Part_68443_5705500.1138217860777
Content-Type: application/octet-stream; name=e100_resume_no_init.diff
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="e100_resume_no_init.diff"

e100: remove init_hw call to fix panic

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

e100 seems to have had a long standing bug where e100_init_hw was being
called when it should not have been.  This caused a panic due to recent
changes that rely on correct set up in the driver, and more robust error
paths.
---

 drivers/net/e100.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2752,8 +2752,6 @@ static int e100_resume(struct pci_dev *p
 	retval = pci_enable_wake(pdev, 0, 0);
 	if (retval)
 		DPRINTK(PROBE,ERR, "Error clearing wake events\n");
-	if(e100_hw_init(nic))
-		DPRINTK(HW, ERR, "e100_hw_init failed\n");
 
 	netif_device_attach(netdev);
 	if(netif_running(netdev))

------=_Part_68443_5705500.1138217860777--
