From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Re: A reliable kernel panic (3.6.2) and system crash when visiting
 a particular website
Date: Mon, 22 Oct 2012 14:01:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210221353440.1724-100000@iolanthe.rowland.org>
References: <1985645001.39510.1350927037793.JavaMail.mail@webmail15>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: zonque@gmail.com, <bp@alien8.de>, <pavel@ucw.cz>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<security@kernel.org>, <linux-media@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <alsa-devel@alsa-project.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1985645001.39510.1350927037793.JavaMail.mail@webmail15>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Oct 2012, Artem S. Tashkinov wrote:

> OK, here's what the kernel prints with your patch:
> 
> usb 6.1.4: ep 86 list del corruption prev: e5103b54 e5103a94 e51039d4
> 
> A small delay before I got thousands of list_del corruption messages would
> have been nice, but I managed to catch the message anyway.

All right.  Here's a new patch, which will print more information and
will provide a 10-second delay.

For this to be useful, you should capture a usbmon trace at the same
time.  The relevant entries will show up in the trace shortly before
_and_ shortly after the error message appears.

Alan Stern

P.S.: It will help if you unplug as many of the other USB devices as
possible before running this test.



Index: usb-3.6/drivers/usb/core/hcd.c
===================================================================
--- usb-3.6.orig/drivers/usb/core/hcd.c
+++ usb-3.6/drivers/usb/core/hcd.c
@@ -1083,6 +1083,8 @@ EXPORT_SYMBOL_GPL(usb_calc_bus_time);
 
 /*-------------------------------------------------------------------------*/
 
+static bool list_error;
+
 /**
  * usb_hcd_link_urb_to_ep - add an URB to its endpoint queue
  * @hcd: host controller to which @urb was submitted
@@ -1193,6 +1195,25 @@ void usb_hcd_unlink_urb_from_ep(struct u
 {
 	/* clear all state linking urb to this dev (and hcd) */
 	spin_lock(&hcd_urb_list_lock);
+	{
+		struct list_head *cur = &urb->urb_list;
+		struct list_head *prev = cur->prev;
+		struct list_head *next = cur->next;
+
+		if (prev->next != cur && !list_error) {
+			list_error = true;
+			dev_err(&urb->dev->dev,
+				"ep %x list del corruption prev: %p %p %p %p %p\n",
+				urb->ep->desc.bEndpointAddress,
+				cur, prev, prev->next, next, next->prev);
+			dev_err(&urb->dev->dev,
+				"head %p urb %p urbprev %p urbnext %p\n",
+				&urb->ep->urb_list, urb,
+				list_entry(prev, struct urb, urb_list),
+				list_entry(next, struct urb, urb_list));
+			mdelay(10000);
+		}
+	}
 	list_del_init(&urb->urb_list);
 	spin_unlock(&hcd_urb_list_lock);
 }
