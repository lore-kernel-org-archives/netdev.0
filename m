From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Configure traffic class to bringup DCB in back-to-back setup
Date: Wed, 13 Jul 2016 10:44:51 -0700
Message-ID: <57867E13.3040708@gmail.com>
References: <loom.20160713T110657-740@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: ayuj <ayuj.verma@gmail.com>, netdev@vger.kernel.org,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33343 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbcGMRpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 13:45:23 -0400
Received: by mail-pf0-f170.google.com with SMTP id i123so20548205pfg.0
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 10:45:09 -0700 (PDT)
In-Reply-To: <loom.20160713T110657-740@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-13 02:09 AM, ayuj wrote:
> I just checked TLV's. Below are the details:
>=20

OK so not really a netdev discussion seeing its just a user
space protocol setup issue. Going forward probably drop
netdev and add intel-wired-lan.

> OS :- CentOS 7.2
> kernel 3.10.0-327.el7.x86_64
> lldpad:- lldpad v0.9.46
> dcbtool:- v0.9.46
> ixgbe :- ixgbe-4.3.15
>=20
> steps followed:-=20
>=20
> # modporbe ixgbe
> # service lldpad start=20
>     Redirecting to /bin/systemctl start  lldpad.service
>=20
> # service lldpad status
> Redirecting to /bin/systemctl status  lldpad.service
> =E2=97=8F lldpad.service - Link Layer Discovery Protocol Agent Daemon=
=2E
>    Loaded: loaded (/usr/lib/systemd/system/lldpad.service; disabled; =
vendor
> preset: disabled)
>    Active: active (running) since Tue 2016-07-05 05:49:12 EDT; 1s ago
>  Main PID: 133737 (lldpad)
>    CGroup: /system.slice/lldpad.service
>            =E2=94=94=E2=94=80133737 /usr/sbin/lldpad -t
>=20
> Jul 05 05:49:12 localhost.localdomain systemd[1]: Started Link Layer
> Discovery Protocol Agent Daemon..
> Jul 05 05:49:12 localhost.localdomain systemd[1]: Starting Link Layer
> Discovery Protocol Agent Daemon....
>=20
> lldptool -t -i p3p2 -n
> Chassis ID TLV
> 	MAC: 00:1b:21:bb:2e:da
> Port ID TLV
> 	MAC: 00:1b:21:bb:2e:da
> Time to Live TLV
> 	120
> IEEE 8021QAZ ETS Configuration TLV
> 	 Willing: yes
> 	 CBS: not supported
> 	 MAX_TCS: 8
> 	 PRIO_MAP: 0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0=20
> 	 TC Bandwidth: 0% 0% 0% 0% 0% 0% 0% 0%=20
> 	 TSA_MAP: 0:strict 1:strict 2:strict 3:strict 4:strict 5:strict 6:st=
rict
> 7:strict=20
> IEEE 8021QAZ PFC TLV
> 	 Willing: yes
> 	 MACsec Bypass Capable: no
> 	 PFC capable traffic classes: 8
> 	 PFC enabled: none
> End of LLDPDU TLV
>=20
> Please help me in configuring traffic classes. I want to bringup DCB =
setup
> in a back-to-back senario.
>=20

So at the moment it appears to be configured to use 802.1QAZ spec which
superseded the older spec even though lldpad supports both. Note the
tool itself really requires some spec knowledge to use correctly. The
spec to read is 802.1Q.

To configure it back-to-back (typical scenario is connected to a DCB
enabled switch where your administrator would setup the switch and this
would autoneg just fine) the servers need to be setup manually.

Perhaps reading if you haven't already the man page for lldptool and
lldptool-ets, lldptool-pfc would help. From the ets man page this
should kick things off,


#lldptool -T -i eth2 -V ETS-CFG \
          tsa=3D0:ets,1:ets,2:ets,3:ets,4:ets,5:ets,6:ets,7:ets \
          up2tc=3D0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7 \
          tcbw=3D12,12,12,12,13,13,13,13


#lldptool -T -i eth2 -V ETS-REC \
           tsa=3D0:ets,1:ets,2:ets,3:ets,4:ets,5:ets,6:ets,7:ets \
           up2tc=3D0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7 \
           tcbw=3D12,12,12,12,13,13,13,13

Thanks,
John
