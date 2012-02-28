From: Jason Wessel <jason.wessel@windriver.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Tue, 28 Feb 2012 10:06:44 -0600
Message-ID: <4F4CFB94.2080302@windriver.com>
References: <628860779.1621452.1330385635262.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrei Warkentin <andreiw@vmware.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>, kgdb-bugreport@lists.sourceforge.net
To: Andrei Warkentin <awarkentin@vmware.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <628860779.1621452.1330385635262.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 02/27/2012 05:33 PM, Andrei Warkentin wrote:
>> From: "Jason Wessel" <jason.wessel@windriver.com>
>> To: "Andrei Warkentin" <andrey.warkentin@gmail.com>
>> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
>> kgdb-bugreport@lists.sourceforge.net, "Matt Mackall" <mpm@selenic.com>
>> Sent: Monday, February 27, 2012 6:17:12 PM
>> Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
>>
>>
>> I am just now starting to look how this patch set compares to kgdboe.
>>  For the kgdboe the patch is a bit different.  The kgdboe opted to
>> just pass the skb so as to cut down on the number of arguments to
>> the function call.
>>
>> From the kgdboe patch:
>>
>> -       void (*rx_hook)(struct netpoll *, int, char *, int);
>> +       void (*rx_hook)(struct netpoll *, int, char *, int, struct
>> sk_buff *);
>>
>>
> 
> Interesting, I thought about passing the skb, but decided I didn't
> want to copy and paste the skb parsing code, especially given
> that it's always UDP anyway. I still have reservations about
> passing the physical address, but I don't think anyone tried
> to use netpoll or a non-ethernet device anyway.


With some input from the netdev folks we should decide what makes the most sense and stick with that implementation.  The previous kgdboe change to just pass the skb was signed off long ago as something ok.

>> +	while (atomic_read(&in_count) == 0)
>> +		netpoll_poll(&np);
>>
>>
>> If it is the case that you really can safely call the
>> netpoll_poll_dev() without the locks then the horrible sync irq
>> state etc... could go away in kgdboe, and then it would be worth
>> considering digging up all the ethernet polling errata fixes that
>> live of out the mainline and perhaps submit some for review.
>>


The code has changed since the last time that kgdboe actually worked.
The v3.1 commit 234b921dbcf killed off the netpoll_poll() function
as well as the exports needed to allow kgdboe to work as a kernel
module.  The patch you created here also needs to once again export
the netpoll_poll_dev() so that we can call it from a kernel module
because kgdboe or the ethernet kdb patch you submitted should be able
to be used a loadable module as well as a builtin.

> 
> I didn't look deeply at kgdboe (probably should have...). Anyway, netpoll_poll
> doesn't seem to exist. netpoll_poll_dev is called from netpoll_send_skb_on_dev
> and the only contract I see is running with the interrupts disabled - something
> that is satisfied by running in the context of KDB.


All that netpoll_poll() did was to call netpoll_poll_dev().  I have
not yet looked at the differences between kgdboe and the netkdb code
you proposed but I would have suspected it also falls victim to the
ethernet preemption problem which prevented kgdboe from ever being
considered for a mainline merge.  Certainly there are ways to fix this
problem but most involved changes to scheduling, core net code, or
substantial driver specific changes.

I almost have kgdboe working against the 3.3 kernel so we can have
both a code and functional comparison.  I would like to do some house
cleaning and merging of all the other out of tree patches for things
like kgdb over usb as well as kdb usb keyboard, so we can see if any
of it makes sense to submit to the mainline.


> 
> This is slight OT, but...are WiFi drivers sufficiently similar that netpoll "just works?"

Yes and no.  Yes, you could use the NET_POLL api to transmit packets
if the driver implemented polling hooks, but no in the sense that most
of the time you need a user space driver to manage the keys which are
time sensitive for things like WPA (usually the job of wpa
supplicant).  This is going to prevent you from having WiFi work at
all while the kernel is in the critical exception state.

Jason.

------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
