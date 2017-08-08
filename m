From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/6] In-kernel QMI handling
Date: Tue, 8 Aug 2017 08:15:47 +0200
Message-ID: <7419F0FF-C2DE-418F-94F1-39F1D4667535@holtmann.org>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
 <1501860967.939.6.camel@redhat.com> <20170807173842.GI29306@minitux>
 <08647880-96CF-4A0A-A75D-0A324022CF32@holtmann.org>
 <20170808044507.GJ29306@minitux>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Dan Williams <dcbw@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        Netdev list <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170808044507.GJ29306@minitux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

>>>>> This series starts by moving the common definitions of the QMUX
>>>>> protocol to the
>>>>> uapi header, as they are shared with clients - both in kernel and
>>>>> userspace.
>>>>> 
>>>>> This series then introduces in-kernel helper functions for aiding the
>>>>> handling
>>>>> of QMI encoded messages in the kernel. QMI encoding is a wire-format
>>>>> used in
>>>>> exchanging messages between the majority of QRTR clients and
>>>>> services.
>>>> 
>>>> This raises a few red-flags for me.
>>> 
>>> I'm glad it does. In discussions with the responsible team within
>>> Qualcomm I've highlighted a number of concerns about enabling this
>>> support in the kernel. Together we're continuously looking into what
>>> should be pushed out to user space, and trying to not introduce
>>> unnecessary new users.
>>> 
>>>> So far, we've kept almost everything QMI related in userspace and
>>>> handled all QMI control-channel messages from libraries like libqmi or
>>>> uqmi via the cdc-wdm driver and the "rmnet" interface via the qmi_wwan
>>>> driver.  The kernel drivers just serve as the transport.
>>>> 
>>> 
>>> The path that was taken to support the MSM-style devices was to
>>> implement net/qrtr, which exposes a socket interface to abstract the
>>> physical transports (QMUX or IPCROUTER in Qualcomm terminology).
>>> 
>>> As I share you view on letting the kernel handle the transportation only
>>> the task of keeping track of registered services (service id -> node and
>>> port mapping) was done in a user space process and so far we've only
>>> ever have to deal with QMI encoded messages in various user space tools.
>> 
>> I think that the transport and multiplexing can be in the kernel as
>> long as it is done as proper subsystem. Similar to Phonet or CAIF.
>> Meaning it should have a well defined socket interface that can be
>> easily used from userspace, but also a clean in-kernel interface
>> handling.
>> 
> 
> In a mobile Qualcomm device there's a few different components involved
> here: message routing, QMUX protocol and QMI-encoding.
> 
> The downstream Qualcomm kernel implements the two first in the
> IPCROUTER, upstream this is split between the kernel net/qrtr and a user
> space service-register implementing the QMUX protocol for knowing where
> services are located.

as long as all of QMUX moves into the kernel and userspace doesn’t need to know about QMUX anymore, that would be good. The cross termination of QMUX in kernel space and userspace is a really bad idea. It is even worse if userspace has to do service registration. That is just a recipe for disaster.

One extra thing to keep in mind is that all the USB dongle should register with such a new QMI subsystem. And have their network interfaces being proper children of the QMI node. And please do not forget QMI passthrough via MBIM. Just saying we move some QMUX code into the kernel is not enough. It really needs to be a proper subsystem with a proper hierarchy of the child devices.

> The common encoding of messages passed between endpoints of the message
> routing is QMI, which is made an affair totally that of each client.
> 
>> If Qualcomm is supportive of this effort and is willing to actually
>> assist and/or open some of the specs or interface descriptions, then
>> this is a good thing. Service registration and cleanup is really done
>> best in the kernel. Same applies to multiplexing. Trying to do
>> multiplexing in userspace is always cumbersome and leads to overhead
>> that is of no gain. For example within oFono, we had to force
>> everything to go via oFono since it was the only sane way of handling
>> it. Other approaches were error prone and full of race conditions. You
>> need a central entity that can clean up.
>> 
> 
> The current upstream solution depends on a collaboration between
> net/qrtr and the user space service register for figuring out whom to
> send messages to. After that muxing et al is handled by the socket
> interface and service registry does not need to be involved.
> 
> Qualcomm is very supporting of this solution and we're collaborating on
> transitioning "downstream" to use this implementation.

It would be good if someone looks into oFono and makes sure that it works there as well. I would prefer at least some initial patches to proof-point the kernel APIs. oFono is a full telephony stack. So if you can make that one work, then you are most likely on the right track.

>> For the definition of an UAPI to share some code, I am actually not
>> sure that is such a good idea. For example the QMI code in oFono
>> follows a way simpler approach. And I am not convinced that all the
>> macros are actually beneficial. For example, the whole netlink macros
>> are pretty cumbersome. Adding some Documentation/qmi.txt on how the
>> wire format looks like and what is expected seems to be a way better
>> approach.
>> 
> 
> The socket interface provided by the kernel expects some knowledge of
> the QMUX protocol, for service management. The majority of this
> knowledge is already public, but I agree that it would be good to gather
> this in a document. The common data structure for the control message is
> what I've put in the uapi, as this is used by anyone dealing with
> control messages.
> 
> When it comes to the QMI-encoded messages these are application
> specific, just like e.g. protobuf definitions are application specific.

That is fine, but what I like to see is at least a documentation that clearly documents the boundaries and examples on how the socket interface is suppose to use. For example using DMS to get the model id etc. would be a simple enough example that could be easily added.

> As the core infrastructure is becoming available upstream and boards
> like the DB410c and DB820c aim to be supported by open solutions we will
> have a natural place to discuss publication of at least some of the
> application level protocols.

I would really welcome public documentation of it. That would be great.

Regards

Marcel
