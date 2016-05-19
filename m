From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v11 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
Date: Wed, 18 May 2016 18:05:40 -0700
Message-ID: <20160519010540.GA3520@kroah.com>
References: <1463331162-6679-1-git-send-email-decui@microsoft.com>
 <20160515.131606.1794366975297405715.davem@davemloft.net>
 <BLUPR03MB141097E05C16CB619E942AA2BF480@BLUPR03MB1410.namprd03.prod.outlook.com>
 <BLUPR03MB1410BB9D04D0758840F6685CBF4A0@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>, "joe@perches.com" <joe@perches.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <BLUPR03MB1410BB9D04D0758840F6685CBF4A0@BLUPR03MB1410.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2016 at 12:59:09AM +0000, Dexuan Cui wrote:
> > From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On Behalf
> > Of Dexuan Cui
> > Sent: Tuesday, May 17, 2016 10:46
> > To: David Miller <davem@davemloft.net>
> > Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; jasowang@redhat.com;
> > linux-kernel@vger.kernel.org; joe@perches.com; netdev@vger.kernel.org;
> > apw@canonical.com; devel@linuxdriverproject.org; Haiyang Zhang
> > <haiyangz@microsoft.com>
> > Subject: RE: [PATCH v11 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
> > 
> > > From: David Miller [mailto:davem@davemloft.net]
> > > Sent: Monday, May 16, 2016 1:16
> > > To: Dexuan Cui <decui@microsoft.com>
> > > Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> > > kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> > > apw@canonical.com; jasowang@redhat.com; cavery@redhat.com; KY
> > > Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> > > joe@perches.com; vkuznets@redhat.com
> > > Subject: Re: [PATCH v11 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
> > >
> > > From: Dexuan Cui <decui@microsoft.com>
> > > Date: Sun, 15 May 2016 09:52:42 -0700
> > >
> > > > Changes since v10
> > > >
> > > > 1) add module params: send_ring_page, recv_ring_page. They can be used
> > to
> > > > enlarge the ringbuffer size to get better performance, e.g.,
> > > > # modprobe hv_sock  recv_ring_page=16 send_ring_page=16
> > > > By default, recv_ring_page is 3 and send_ring_page is 2.
> > > >
> > > > 2) add module param max_socket_number (the default is 1024).
> > > > A user can enlarge the number to create more than 1024 hv_sock sockets.
> > > > By default, 1024 sockets take about 1024 * (3+2+1+1) * 4KB = 28M bytes.
> > > > (Here 1+1 means 1 page for send/recv buffers per connection, respectively.)
> > >
> > > This is papering around my objections, and create module parameters which
> > > I am fundamentally against.
> > >
> > > You're making the facility unusable by default, just to work around my
> > > memory consumption concerns.
> > >
> > > What will end up happening is that everyone will simply increase the
> > > values.
> > >
> > > You're not really addressing the core issue, and I will be ignoring you
> > > future submissions of this change until you do.
> > 
> > David,
> > I am sorry I came across as ignoring your feedback; that was not my intention.
> > The current host side design for this feature is such that each socket connection
> > needs its own channel, which consists of
> > 
> > 1.    A ring buffer for host to guest communication
> > 2.    A ring buffer for guest to host communication
> > 
> > The memory for the ring buffers has to be pinned down as this will be accessed
> > both from interrupt level in Linux guest and from the host OS at any time.
> > 
> > To address your concerns, I am planning to re-implement both the receive path
> > and the send path so that no additional pinned memory will be needed.
> > 
> > Receive Path:
> > When the application does a read on the socket, we will dynamically allocate
> > the buffer and perform the read operation on the incoming ring buffer. Since
> > we will be in the process context, we can sleep here and will set the
> > "GFP_KERNEL | __GFP_NOFAIL" flags. This buffer will be freed once the
> > application consumes all the data.
> > 
> > Send Path:
> > On the send side, we will construct the payload to be sent directly on the
> > outgoing ringbuffer.
> > 
> > So, with these changes, the only memory that will be pinned down will be the
> > memory for the ring buffers on a per-connection basis and this memory will be
> > pinned down until the connection is torn down.
> > 
> > Please let me know if this addresses your concerns.
> > 
> > -- Dexuan
> 
> Hi David,
> Ping. Really appreciate your comment.

Don't wait for people to respond to random design questions, go work on
the code and figure out if it is workable or not yourself.  Then post
patches.  We aren't responsible for your work, you are.

greg k-h
