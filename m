From: yuval.shaia@oracle.com
Subject: Re: [PATCH] Add support for netconsole driver used on
 bridge device with VIF attached
Date: Tue, 29 Jan 2013 10:47:49 +0200
Message-ID: <51078CB5.3080805@oracle.com>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default>
	<1358789308.3279.271.camel@zakaz.uk.xensource.com>
	<50FD8243.6000501@oracle.com>
	<1358846612.3279.282.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5937593137598979388=="
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1358846612.3279.282.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============5937593137598979388==
Content-Type: multipart/alternative;
 boundary="------------080602040708060308020503"

This is a multi-part message in MIME format.
--------------080602040708060308020503
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


On 01/22/2013 11:23 AM, Ian Campbell wrote:
> On Mon, 2013-01-21 at 18:00 +0000, yuval.shaia@oracle.com wrote:
>> On 01/21/2013 07:28 PM, Ian Campbell wrote:
>>> On Mon, 2013-01-21 at 17:17 +0000, Yuval Shaia wrote:
>>>
>>>> When starting a VM which has virtual interface attached to the same
>>>> bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is
>>>> used for netconsole the
>>>> following message appears (after about 60 seconds) and VM creation
>>>> operation fails.
>>>>         Error: Device 0 (vif) could not be connected. Hotplug scripts not
>>>> working.
>>> I'm not sure how this can relate netconsole since this happens before
>>> the guest even runs, doesn't it?
>> Running the same scenario without netconsole runs smoothly.
> But why? I can't make sense of your scenario and therefore cannot
> explain why this patch would make any difference. Perhaps your patch is
> just papering over some other issue?
>
>>>> As i see it, netconsole driver requires ndo_poll_controller from the
>>>> device's controlling driver (function __netpoll_setup in
>>>> net/core/netpoll.c), a thing that is not supported currently in
>>>> xen_netback driver which is the driver that runs on dom0 and serve
>>>> VM's virtual interface.
>>> Which domain is using netconsole? Is it dom0 or domU? What parameters do
>>> you give it?
>> dom0.
>> parameters: netconsole=1111@src-ip/xenbr0,2002@dst-ip/dst-mac
> You give these parameters to dom0 so that dom0's own logs are sent to
> some other host?
>
> Are dst-ip and dst-mac a domain on the same host or are they some offbox
> logging service?

Sorry, my mistake, i should have attach network setup at first.

Anyway, here is my setup:
---------- ----------
| Host A |--bond0 -- | Host B |
|--------| |--xenbr0 | |
| VM A1 |--vif1.0 -- | | |
---------- | ----------
| |
---------------------------------------------
| LAN |
---------------------------------------------


I'm using netconsole to capture logs from Host-A and send them to Host-B.
Host-A and Host-B are separate hosts (running XEN) which are connected 
to the same LAN.

src-ip is Host-A address.
dst-ip/mac is Host-B address.

>
> I can see why the *bridge* device might need an ndo_poll_controller hook
> in this setup but I can't see any reason why the netback device would
> need one.
Please note that without netback driver netconsole runs fine, i.e before 
trying to create VM which attached to the bridge.
>
>>> I assume it is the domU but if that's the case I don't see why a netback
>>> rather than netfront patch would be required.
>>>
>>> Or is dom0 doing netconsole where the log receiver is a domU?
>> Log received at dom0 as output of xm cr vm.cfg command.
>> netconsole is used on dom0 to monitor its log
> Are you now saying that logging goes from domU to dom0? Which is it?
>
> In this scenario there is really no reason I can see that netback would
> need an ndo_poll_controller hook -- that would be needed in the domU in
> the netfront driver.
netback comes to play as soon as i'm attaching virtual interface to a 
bridge and since this bridge is under netconsole monitoring the function 
is triggered. Up to that point there is no issue getting logs in Host-B 
so i assume the problem is not with the bridge driver.
>
> Please can you explain the exact code path which results in this new
> hook being called.
init_netconsole() in netconsole.c -> alloc_param_target() -> 
netpoll_setup() in netpoll.c -> __netpoll_setup() which check if 
ndo_poll_controller() operation is supported.
>
> BTW looking at the patch as it is any use of this hook should be wrapped
> in CONFIG_NET_POLL_CONTROLLER.
>
> Ian.
>


--------------080602040708060308020503
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <br>
    <div class="moz-cite-prefix">On 01/22/2013 11:23 AM, Ian Campbell
      wrote:<br>
    </div>
    <blockquote
      cite="mid:1358846612.3279.282.camel@zakaz.uk.xensource.com"
      type="cite">
      <pre wrap="">On Mon, 2013-01-21 at 18:00 +0000, <a class="moz-txt-link-abbreviated" href="mailto:yuval.shaia@oracle.com">yuval.shaia@oracle.com</a> wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">On 01/21/2013 07:28 PM, Ian Campbell wrote:
</pre>
        <blockquote type="cite">
          <pre wrap="">On Mon, 2013-01-21 at 17:17 +0000, Yuval Shaia wrote:

</pre>
          <blockquote type="cite">
            <pre wrap="">When starting a VM which has virtual interface attached to the same
bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is
used for netconsole the
following message appears (after about 60 seconds) and VM creation
operation fails.
       Error: Device 0 (vif) could not be connected. Hotplug scripts not
working.
</pre>
          </blockquote>
          <pre wrap="">I'm not sure how this can relate netconsole since this happens before
the guest even runs, doesn't it?
</pre>
        </blockquote>
        <pre wrap="">Running the same scenario without netconsole runs smoothly.
</pre>
      </blockquote>
      <pre wrap="">
But why? I can't make sense of your scenario and therefore cannot
explain why this patch would make any difference. Perhaps your patch is
just papering over some other issue?

</pre>
      <blockquote type="cite">
        <blockquote type="cite">
          <blockquote type="cite">
            <pre wrap="">As i see it, netconsole driver requires ndo_poll_controller from the
device's controlling driver (function __netpoll_setup in
net/core/netpoll.c), a thing that is not supported currently in
xen_netback driver which is the driver that runs on dom0 and serve
VM's virtual interface.
</pre>
          </blockquote>
          <pre wrap="">Which domain is using netconsole? Is it dom0 or domU? What parameters do
you give it?
</pre>
        </blockquote>
        <pre wrap="">dom0.
parameters: netconsole=1111@src-ip/xenbr0,2002@dst-ip/dst-mac
</pre>
      </blockquote>
      <pre wrap="">
You give these parameters to dom0 so that dom0's own logs are sent to
some other host? 

Are dst-ip and dst-mac a domain on the same host or are they some offbox
logging service?</pre>
    </blockquote>
    <meta name="qrichtext" content="1">
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px;
      margin-right:0px; -qt-block-indent:0; text-indent:0px;
      -qt-user-state:0;"><!--StartFragment--><span style="
        font-family:'Sans Serif'; font-size:10pt;">Sorry, my mistake, i
        should have attach network setup at first.</span></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px;
      margin-right:0px; -qt-block-indent:0; text-indent:0px;
      -qt-user-state:0;"><span style=" font-family:'Sans Serif';
        font-size:10pt;">Anyway, here is my setup:<br>
        ---------- ----------<br>
        | Host A |--bond0 -- | Host B |<br>
        |--------| |--xenbr0 | |<br>
        | VM A1 |--vif1.0 -- | | |<br>
        ---------- | ----------<br>
        | |<br>
        ---------------------------------------------<br>
        | LAN |<br>
        ---------------------------------------------<br>
      </span></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px;
      margin-right:0px; -qt-block-indent:0; text-indent:0px;
      -qt-user-state:0;"><br>
      <span style=" font-family:'Sans Serif'; font-size:10pt;"></span></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px;
      margin-right:0px; -qt-block-indent:0; text-indent:0px;
      -qt-user-state:0;"><span style=" font-family:'Sans Serif';
        font-size:10pt;">I'm using netconsole to capture logs from
        Host-A and send them to Host-B.<br>
        Host-A and Host-B are separate hosts (running XEN) which are
        connected to the same LAN.<br>
      </span></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px;
      margin-right:0px; -qt-block-indent:0; text-indent:0px;
      -qt-user-state:0;"><span style=" font-family:'Sans Serif';
        font-size:10pt;">src-ip is Host-A address.<br>
        dst-ip/mac is Host-B address.<br>
      </span><!--EndFragment--></p>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <style type="text/css">
p, li { white-space: pre-wrap; }
</style>
    <blockquote
      cite="mid:1358846612.3279.282.camel@zakaz.uk.xensource.com"
      type="cite">
      <pre wrap="">

I can see why the *bridge* device might need an ndo_poll_controller hook
in this setup but I can't see any reason why the netback device would
need one.</pre>
    </blockquote>
    Please note that without netback driver netconsole runs fine, i.e
    before trying to create VM which attached to the bridge.<br>
    <blockquote
      cite="mid:1358846612.3279.282.camel@zakaz.uk.xensource.com"
      type="cite">
      <pre wrap="">

</pre>
      <blockquote type="cite">
        <blockquote type="cite">
          <pre wrap="">
I assume it is the domU but if that's the case I don't see why a netback
rather than netfront patch would be required.

Or is dom0 doing netconsole where the log receiver is a domU?
</pre>
        </blockquote>
        <pre wrap="">Log received at dom0 as output of xm cr vm.cfg command.
netconsole is used on dom0 to monitor its log
</pre>
      </blockquote>
      <pre wrap="">
Are you now saying that logging goes from domU to dom0? Which is it?

In this scenario there is really no reason I can see that netback would
need an ndo_poll_controller hook -- that would be needed in the domU in
the netfront driver.</pre>
    </blockquote>
    netback comes to play as soon as i'm attaching virtual interface to
    a bridge and since this bridge is under netconsole monitoring the
    function is triggered. Up to that point there is no issue getting
    logs in Host-B so i assume the problem is not with the bridge
    driver.<br>
    <blockquote
      cite="mid:1358846612.3279.282.camel@zakaz.uk.xensource.com"
      type="cite">
      <pre wrap="">

Please can you explain the exact code path which results in this new
hook being called.</pre>
    </blockquote>
    init_netconsole() in netconsole.c -&gt; alloc_param_target() -&gt;
    netpoll_setup() in netpoll.c -&gt; __netpoll_setup() which check if
    ndo_poll_controller() operation is supported.<br>
    <blockquote
      cite="mid:1358846612.3279.282.camel@zakaz.uk.xensource.com"
      type="cite">
      <pre wrap="">

BTW looking at the patch as it is any use of this hook should be wrapped
in CONFIG_NET_POLL_CONTROLLER.

Ian.

</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------080602040708060308020503--


--===============5937593137598979388==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============5937593137598979388==--
