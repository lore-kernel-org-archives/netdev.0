From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: set is_local and is_static before
 fdb entry is added to the fdb hashtable
Date: Tue, 27 Oct 2015 07:55:30 -0700
Message-ID: <562F9062.2080100@cumulusnetworks.com>
References: <1445947922-12236-1-git-send-email-roopa@cumulusnetworks.com> <562F7CC4.6040604@cumulusnetworks.com> <20151027.070255.918332804045095898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nikolay@cumulusnetworks.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35543 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674AbbJ0Ozc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:55:32 -0400
Received: by pasz6 with SMTP id z6so224739633pas.2
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 07:55:31 -0700 (PDT)
In-Reply-To: <20151027.070255.918332804045095898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/15, 7:02 AM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Tue, 27 Oct 2015 14:31:48 +0100
>
>> On 10/27/2015 01:12 PM, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> Problem Description:
>>> We can add fdbs pointing to the bridge with NULL ->dst but that has=
 a
>>> few race conditions because br_fdb_insert() is used which first cre=
ates
>>> the fdb and then, after the fdb has been published/linked, sets
>>> "is_local" to 1 and in that time frame if a packet arrives for that=
 fdb
>>> it may see it as non-local and either do a NULL ptr dereference in
>>> br_forward() or attach the fdb to the port where it arrived, and la=
ter
>>> br_fdb_insert() will make it local thus getting a wrong fdb entry.
>>> Call chain br_handle_frame_finish() -> br_forward():
>>> But in br_handle_frame_finish() in order to call br_forward() the d=
st
>>> should not be local i.e. skb !=3D NULL, whenever the dst is
>>> found to be local skb is set to NULL so we can't forward it,
>>> and here comes the problem since it's running only
>>> with RCU when forwarding packets it can see the entry before "is_lo=
cal"
>>> is set to 1 and actually try to dereference NULL.
>>> The main issue is that if someone sends a packet to the switch whil=
e
>>> it's adding the entry which points to the bridge device, it may
>>> dereference NULL ptr. This is needed now after we can add fdbs
>>> pointing to the bridge.  This poses a problem for
>>> br_fdb_update() as well, while someone's adding a bridge fdb, but
>>> before it has is_local =3D=3D 1, it might get moved to a port if it=
 comes
>>> as a source mac and then it may get its "is_local" set to 1
>>>
>>> This patch changes fdb_create to take is_local and is_static as
>>> arguments to set these values in the fdb entry before it is added t=
o the
>>> hash. Also adds null check for port in br_forward.
>>>
>>> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>> v2 - fix compile error reported by kbuild test robot.
>>>      Accidently i had posted an older version of the patch
>>>
>> Thanks for fixing this,
>>
>> Fixes: 3741873b4f73 ("bridge: allow adding of fdb entries pointing t=
o the bridge device")
>> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> This still doesn't compile:
>
> net/bridge/br_fdb.c: In function =A1br_fdb_external_learn_add=A2:
> net/bridge/br_fdb.c:1103:3: error: too few arguments to function =A1f=
db_create=A2
> net/bridge/br_fdb.c:495:37: note: declared here
sorry david about the sloppiness. Resent. There was a problem with my p=
atch generation.
