From: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Subject: Re: [PATCH] Bluetooth: hci_smd: Qualcomm WCNSS HCI driver
Date: Thu, 8 Oct 2015 10:07:44 -0700
Message-ID: <20151008170744.GF24668@usrtlx11787.corpusers.net>
References: <1443654180-29416-1-git-send-email-bjorn.andersson@sonymobile.com>
 <036E1E75-8E6A-4116-A648-A188A8458416@holtmann.org>
 <20151001203338.GW24668@usrtlx11787.corpusers.net>
 <31CC1992-41BB-484C-9784-3A54D0EF6FF3@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fengwei Yin <fengwei.yin@linaro.org>,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>, <agross@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <31CC1992-41BB-484C-9784-3A54D0EF6FF3@holtmann.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 03 Oct 09:55 PDT 2015, Marcel Holtmann wrote:

> Hi Bjorn,
> 
[..]
> >> Especially the kbuild test robot complained loudly.
> >>
> >
> > Sorry, I forgot to mention in the patch that the patch depends on the
> > qcom_smd_id patch - that's available in linux-next. I will take another
> > look, but I think that was the cause of all the issues.
> 
> which means, I can only merge this driver when this other patch has
> hit net-next tree. Unless I take the qcom_smd_id through
> bluetooth-next tree which doesn't look like a good idea.
> 

I was going to suggest that we just wait for -rc1, but the new additions
to SMD adds a bunch of new items on the dependency list.

Perhaps once we agree we can get your Ack and have Andy pull it through
the qcom-soc tree together with the SMD patches?

> >>> obj-$(CONFIG_BT_INTEL)              += btintel.o
> >>> obj-$(CONFIG_BT_ATH3K)              += ath3k.o
> >>> diff --git a/drivers/bluetooth/hci_smd.c b/drivers/bluetooth/hci_smd.c
> > [..]
> >>> +#include <net/bluetooth/hci.h>
> >>
> >> The hci.h include is not needed. If you do, then you are doing
> >> something fishy.
> >>
> >
> > Nothing fishy going on here, so I'll drop it.
> >
> >>> +
> >>> +static struct {
> >>> +   struct qcom_smd_channel *acl_channel;
> >>> +   struct qcom_smd_channel *cmd_channel;
> >>> +
> >>> +   struct hci_dev *hci;
> >>> +} smd_hci;
> >>
> >> A driver that only supports a single instance of a device and uses a
> >> global variable to do so is not a good idea. There should be no reason
> >> for this. Why is this done this way.
> >>
> >
> > There's two channels coming up, each probing the associated driver that
> > combines these into 1 hci device.
> >
> > So I have two options;
> >
> > * the original idea was to implement multi-channel-per-device support in
> >  SMD, but as this is the only known case where that's needed I really
> >  don't want to add all the extra complexity to SMD.
> >
> > * I can accept the fact that this is silicon inside the MSM SoC and
> >  should never exist in more than one instance and make this hack. The
> >  first version I implemented had this structure allocated on the first
> >  probe, but that didn't really add any value to the static struct.
> >
> > I picked the second option due to the fact that the patch to SMD was way
> > bigger then this patch, and full of nasty logic.
> 
> Writing a driver that assume it is a single instance of a given device
> is never a good idea. While you might find some instances in the
> kernel if you look hard enough, but that doesn't mean we should keep
> doing this. So this needs addressing.
> 

Fair enough.

> >
> >>> +
> >>> +static int smd_hci_recv(unsigned type, const void *data, size_t count)
> >>> +{
> >>> +   struct sk_buff *skb;
> >>> +   void *buf;
> >>> +   int ret;
> >>> +
> >>> +   skb = bt_skb_alloc(count, GFP_ATOMIC);
> >>
> >> Is it required that this is GFP_ATOMIC or can this actually be
> >> GFP_KERNEL?
> >>
> >
> > This is being called from IRQ context upon receiving data on the
> > channels.
> 
> I wonder why that is needed, but seems an issue in the SMD subsystem.
> So this is fine, might want to add a comment above the bt_skb_alloc to
> remind us.
> 

It's a design choice of mine, to deliver the incoming data directly from
the interrupt handler. Sure enough we could have had a worker thread or
something do it.

I'll add a comment.

> >
> >>> +   if (!skb)
> >>> +           return -ENOMEM;
> >>> +
> >>> +   buf = skb_put(skb, count);
> >>> +   memcpy_fromio(buf, data, count);
> >>
> >> Why is this a memcpy_fromio here?
> >>
> >
> > A memcpy here doesn't seem to work on ARM64, probably because the
> > pointer references ioremapped memory. We are discussing either marking
> > the data __iomem or perhaps using memremap rather then ioremap.
> 
> I would add a comment here as well to remind everybody why this is
> used. And marking up the pointers is a good idea as well.
> 

Yeah, I have this on the todo.
Will put a comment here for now.

[..]

> >>> +
> >>> +   return ret;
> >>> +}
> >>> +
> >>> +static int smd_hci_open(struct hci_dev *hci)
> >>> +{
> >>> +   return 0;
> >>> +}
> >>> +
> >>> +static int smd_hci_close(struct hci_dev *hci)
> >>> +{
> >>> +   return 0;
> >>> +}
> >>
> >> These two need to at least handling the HCI_RUNNING flag setting and
> >> clearing like all the other drivers do.
> >>
> >
> > I'm puzzled to the purpose of this, is this only for indication to user
> > space or am I missing something?
> >
> > I found a couple of others that does nothing but set and clear this bit
> > in their open and close. Would you be open for a framework patch that
> > provides this functionality to drivers that doesn't need anything else?
> 
> This has been in the drivers for as long as the Bluetooth subsystem
> has been merged upstream. So Linux 2.4.6 to be precise. I had plans to
> move this code into the core, but that has not happened yet. So until
> then, lets just include the HCI_RUNNING part.
> 

I'll add the pieces.

> If there are drivers not doing this, then that is a bug and needs to
> be fixed. Please point them out to me.
> 

What I meant was that I couldn't find anyone consuming this bit, the
cases I looked at all fiddled with it in various ways.

But I presume it can be seen from userspace.

> >>> +
> >>> +static int smd_hci_set_bdaddr(struct hci_dev *hci,
> >>> +                         const bdaddr_t *bdaddr)
> >>> +{
> >>> +   u8 buf[12];
> >>> +
> >>> +   buf[0] = 0x0b;
> >>> +   buf[1] = 0xfc;
> >>> +   buf[2] = 0x9;
> >>> +   buf[3] = 0x1;
> >>> +   buf[4] = 0x2;
> >>
> >> Use full 0x00 syntax here.
> >>
> >
> > Ok
> >
> >>> +   buf[5] = sizeof(bdaddr_t);
> >>> +   memcpy(buf + 6, bdaddr, sizeof(bdaddr_t));
> >>
> >> We also need to be sure that this command only changes the BD_ADDR in
> >> RAM. It can not be persistent. When resetting / power cycle the
> >> controller it will fallback to its default.
> >>
> >
> > There seems to be no persistent storage at all in this chip, the BD_ADDR
> > being used comes from one of the firmware files, so this just adjust the
> > in-memory configuration.
> >
> >>> +
> >>> +   return qcom_smd_send(smd_hci.cmd_channel, buf, sizeof(buf));
> >>
> >> Use __hci_cmd_sync since that is what is suppose to be used in this
> >> callback. See the other drivers on how this is done.
> >>
> >
> > I did see this, and I first implemented it like that. Unfortunately the
> > firmware does not ack the command and __hci_cmd_sync() just times out.
> >
> > I didn't manage to find a way around this.
> 
> What to you mean by this? It does not send a Command Complete? Does it
> send a Vendor Event instead?
> 

The immediate problem I had seems to be that I specified the wrong event
type. With this corrected it passes most of the time - but in some cases
I don't get the command complete packet back.

I don't know what causes this and I don't have access to the source code
of the other side :/

> The real problem is that this callback is on purpose synchronous. The
> core relies on the fact that you only return when it actually
> completed.
> 

Makes sense.

> >> I wonder if qca_set_bdaddr_rome is not actually the same command and
> >> you could just use that instead.
> >>
> >
> > Looks to be exactly the same thing and gives insight in what those first
> > 5 bytes are. I'll update the magics based on this information.
> >
> > If I didn't have the issue of the timeout it seems like I should be able
> > to just call it.
> 
> Has something tried to talk to Qualcomm why that timeout happens? They
> have something like this for the UART speed change which is changed in
> NVRAM. Maybe this is a more generic way on how they handle things. It
> would be good if guys from Qualcomm could give some insights here.
> However in case of their UART driver, this seems to work as it should.
> Maybe just a newer firmware is needed.
> 

Unfortunately this part of Qualcomm hasn't joined the dance yet.

When booting the chip we load a file with "NV values", so I presume that
this command allows us to patch those entries in runtime.

[..]
> 
> That is what USB does when claiming a second interface. I would do
> exactly that and especially be able to make sure that both channels
> have the same struct device as parent.
> 

I was hoping to not have to implement this, as it does complicates the
life cycle management of things in the SMD core but agrees with you that
it's cleaner.

I'll finish up the rewrite and send out a new version based on this.

Thanks for the review Marcel!

Regards,
Bjorn
